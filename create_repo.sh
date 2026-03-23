#!/bin/bash
# 1. 创建项目目录结构
#mkdir -p openclaw-adaptive-optimizer/.github/workflows
#mkdir -p openclaw-adaptive-optimizer/.github/ISSUE_TEMPLATE
#cd openclaw-adaptive-optimizer

# 2. 创建核心 Skill 脚本 (adaptive-optimizer.js)
cat <<'EOF' > adaptive-optimizer.js
/**
 * @name AdaptiveWorkspaceOptimizer
 * @version 1.3.0
 * @description Multi-provider RAG optimizer with Model-Affinity detection.
 */

export default {
  name: 'adaptive-optimizer',
  description: 'Self-tuning RAG pipeline with Multi-Provider support.',
  config: {
    workspacePath: './workspace',
    sizeThresholdMB: 1,
    cronSchedule: '0 */12 * * *'
  },
  async run(context) {
    const { fs, memory, logger, agents, auth, config } = context;
    try {
      const mainAgent = await agents.get('main');
      const modelID = (mainAgent.model.primary || 'unknown').toLowerCase();
      const isLargeContext = /pro|ultra|opus|sonnet|grok|qwen|max|large|128k|200k/.test(modelID);
      const isLiteModel = /flash|haiku|mini|lite|small/.test(modelID);

      const profiles = await auth.getProfiles();
      const providerList = Object.values(profiles).map(p => p.provider);
      let targetEmbedding = 'openai/text-embedding-3-small';
      if (providerList.includes('google')) targetEmbedding = 'google/text-embedding-004';
      else if (providerList.includes('anthropic')) targetEmbedding = 'voyage/voyage-3';
      else if (providerList.includes('openrouter')) targetEmbedding = 'openrouter/auto';

      const files = await fs.listFiles(config.workspacePath, { recursive: true, pattern: /\.md$/ });
      let totalBytes = 0;
      for (const f of files) { totalBytes += (await fs.stat(f)).size; }
      const totalMB = totalBytes / (1024 * 1024);

      let strategy = {
        strategy: 'semantic',
        chunkSize: isLargeContext ? 6000 : (isLiteModel ? 1000 : 2500),
        chunkOverlap: isLargeContext ? 500 : 200,
        embeddingModel: targetEmbedding
      };

      if (modelID.includes('claude')) {
        strategy.chunkSize = 8000;
        strategy.chunkOverlap = 800;
      }

      if (totalMB < config.sizeThresholdMB) {
        strategy.strategy = 'full';
        strategy.chunkSize = 0;
      }

      logger.info(`[SSoT-AUDIT] Model: ${modelID} | Strategy: ${strategy.strategy}`);
      if (!config.dryRun) { await memory.reindex({ force: false, ...strategy }); }
      return `Optimized for ${modelID} using ${strategy.strategy} strategy.`;
    } catch (err) {
      logger.error(`[SSoT-AUDIT] Failure: ${err.message}`);
      throw err;
    }
  }
};
EOF

# 3. 创建清单文件 (skill.json)
cat <<EOF > skill.json
{
  "id": "openclaw-adaptive-optimizer",
  "version": "1.3.0",
  "description": "Multi-provider RAG tuning for OpenClaw.",
  "permissions": ["fs:read", "memory:write", "agents:read", "auth:read"],
  "engine": ">=2026.3.13"
}
EOF

# 4. 创建项目说明文档 (README.md)
cat <<EOF > README.md
<p align="center">
  <img src="./repo-icon.png" alt="Icon" width="180px" />
</p>

# OpenClaw Adaptive Workspace Optimizer 🚀

A self-evolving RAG management skill for OpenClaw. It monitors workspace telemetry and applies the optimal chunking strategy based on your active AI provider (Gemini, Claude, Grok, Qwen, etc.).

## 🤖 [AI-AGENT] Deployment
1. Read \`skill.json\` for permissions.
2. Deploy \`adaptive-optimizer.js\` to the \`skills/\` directory.
3. Configure \`openclaw.json\` as per the snippet below.

## ⚙️ Configuration
\`\`\`json
"skills": {
  "adaptive-optimizer": {
    "enabled": true,
    "config": {
      "workspacePath": "./workspace",
      "sizeThresholdMB": 1,
      "cronSchedule": "0 */12 * * *"
    }
  }
}
\`\`\`
EOF

# 5. 创建开发配置文件 (package.json, DEPENDENTS.md, .gitignore)
cat <<EOF > package.json
{
  "name": "openclaw-adaptive-optimizer",
  "version": "1.3.0",
  "type": "module",
  "scripts": { "validate": "node --check adaptive-optimizer.js" }
}
EOF

cat <<EOF > DEPENDENTS.md
# Ecosystem Dependents
Optimized for Google Gemini 3.1 Pro/Flash, Anthropic Claude, x.ai, and Alibaba Qwen.
EOF

echo "node_modules/\n*.log\n.DS_Store" > .gitignore

# 6. 创建 CI 自动化与 Issue 模板
cat <<EOF > .github/workflows/validate.yml
name: CI
on: [push]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: node --check adaptive-optimizer.js
EOF

cat <<EOF > .github/ISSUE_TEMPLATE/model_feedback.md
---
name: "🤖 Model Feedback"
about: Report RAG performance.
---
**Model ID**:
**Feedback**:
EOF

# 7. Git 初始化与推送 (请先在 GitHub 创建空仓库)
git init
git add .
git commit -m "initial release v1.3.0 with multi-provider support"
git branch -M main
# git remote add origin https://github.com/<your-github-username>/openclaw-adaptive-optimizer.git
# git push -u origin main

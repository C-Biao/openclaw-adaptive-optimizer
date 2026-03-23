<p align="center">
  <img src="./repo-icon.png" alt="Icon" width="180px" />
</p>

# OpenClaw Adaptive Workspace Optimizer 🚀

A self-evolving RAG management skill for OpenClaw. It monitors workspace telemetry and applies the optimal chunking strategy based on your active AI provider (Gemini, Claude, Grok, Qwen, etc.).

## 🤖 [AI-AGENT] Deployment
1. Read `skill.json` for permissions.
2. Deploy `adaptive-optimizer.js` to the `skills/` directory.
3. Configure `openclaw.json` as per the snippet below.

## ⚙️ Configuration
```json
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
```

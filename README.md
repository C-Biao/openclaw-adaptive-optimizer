<p align="center">
  <img src="./repo-icon.png" alt="OpenClaw Adaptive Optimizer Icon" width="180px" height="auto" />
</p>

# OpenClaw Adaptive Workspace Optimizer 🚀
![Version](https://img.shields.io/badge/OpenClaw-2026.3.13-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![CI](https://github.com/C-Biao/openclaw-adaptive-optimizer/actions/workflows/validate.yml/badge.svg)

A zero-config, **Provider-Aware** RAG management skill. It monitors your workspace telemetry and applies the optimal chunking strategy based on your active AI provider's architecture (Gemini, Claude, Grok, Qwen, GPT-4o, etc.).

---

## 🤖 [AI-AGENT] Deployment Protocol
If you are an AI Agent installing this:
1. **Source**: Read `skill.json` to verify required permissions (`fs`, `memory`, `agents`, `auth`).
2. **Path Resolution**: Identify the host's `skills/` directory within the OpenClaw environment.
3. **Deployment**: Write the contents of `adaptive-optimizer.js` to the target directory.
4. **Configuration Injection**: Append the JSON block found in the [Configuration](#configuration) section to the user's `openclaw.json` file.

---

## ⚙️ Configuration
Add this to your `openclaw.json`:

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

---

## 🧠 Heuristic Decision Matrix
The optimizer implements a dynamic logic branch to match the "Semantic Density" of your documents with the "Context Window" of your provider.

| Provider | Capability | Chunk Size | Strategy |
| :--- | :--- | :--- | :--- |
| **Anthropic** | Claude Opus/Sonnet | 8000 | Deep-Context |
| **Google** | Gemini 3.1 Pro | 4000 | Semantic-Native |
| **x.ai / OpenAI** | Grok / GPT-4o | 2500 | Window-Sliding |
| **Alibaba / Minimax** | Qwen / Max | 2000 | Header-First |

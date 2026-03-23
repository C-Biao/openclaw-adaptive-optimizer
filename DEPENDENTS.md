# Ecosystem Dependents

This skill acts as a **Foundation Service** for OpenClaw workspaces. It is designed to be a prerequisite for high-density knowledge agents.

## 🔗 Integrated Workflows
- **Research Agents**: Skills that perform heavy web-scraping or document ingestion should trigger `adaptive-optimizer` post-ingestion to ensure the RAG pipeline is calibrated for the new data volume.
- **Multi-Tenant Gateways**: When running parallel agents (e.g., Bill and Weiwei), this skill ensures that each container optimizes its specific workspace independently without cross-contamination.

## 🏗️ Compatibility Layer
- **Primary Provider**: Optimized for Google Gemini 1.5/3.1 Pro/Flash.
- **Secondary Providers**: Native support for Anthropic (Claude), x.ai (Grok), Alibaba (Qwen), and OpenRouter.
- **Embedding Alignment**: Automatically maps `google/text-embedding-004` or `voyage/voyage-3` based on available `auth.profiles`.

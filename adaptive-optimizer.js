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

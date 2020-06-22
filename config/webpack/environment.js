const { environment } = require('@rails/webpacker')
const jquery = require('./plugins/jquery')

environment.config.set("output.filename", chunkData => {
  // if the name of the pack is "widget" then exclude the chunk hash
  if (chunkData.chunk.name === "campaign") return "campaign.js";
  // otherwise fingerprint the asset
  return "[name].[chunkhash].js";
});

environment.plugins.prepend('jquery', jquery)
module.exports = environment

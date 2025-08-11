const path = require('path');
module.exports = {
  typescript: {
    ignoreBuildErrors: true
  }, // TEMP
  eslint: {
    ignoreDuringBuilds: true
  }, // TEMP
  webpack: (config) => {
    config.resolve.alias['@'] = path.resolve(__dirname, 'src');
    return config;
  },
};

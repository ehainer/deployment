const path = require('path');

module.exports = {
  resolve: {
    alias: {
      vue: 'vue/dist/vue',
      jquery: 'jquery/src/jquery',
      cookie: 'js-cookie/src/js.cookie',
      '@components': path.resolve(__dirname, '../../app/javascript/components'),
      '@plugins': path.resolve(__dirname, '../../app/javascript/plugins'),
      '@store': path.resolve(__dirname, '../../app/javascript/store'),
      '@vendor': path.resolve(__dirname, '../../app/javascript/vendor'),
      '@includes': path.resolve(__dirname, '../../app/javascript/includes')
    },
  },
  stats: 'errors-only',
  devtool: 'source-map',
};

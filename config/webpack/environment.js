const { environment } = require('@rails/webpacker');
const vue = require('./loaders/vue');
const shared = require('./shared');
const webpack = require('webpack');

environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Vue: 'vue',
    Axios: 'axios'
  })
);

environment.loaders.append('vue', vue);
environment.config.merge(shared);
module.exports = environment;

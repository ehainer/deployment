const path = require('path');
const { dev_server: devServer } = require('@rails/webpacker').config;

const isProduction = process.env.NODE_ENV === 'production';
const inDevServer = process.argv.find(v => v.includes('webpack-dev-server'));
const extractCSS = !(inDevServer && (devServer && devServer.hmr)) || isProduction;

module.exports = {
  test: /\.vue(\.erb)?$/,
  use: [
    {
      loader: 'vue-loader',
      options: {
        extractCSS,
        loaders: {
          js: 'babel-loader',
          scss: [
            'vue-style-loader',
            'css-loader',
            'sass-loader',
            //{
            //  loader: 'sass-resources-loader',
            //  options: {
            //    resources: [
            //      //path.resolve(__dirname, '../../../app/javascript/assets/stylesheets/modules/_fonts.scss'),
            //      //path.resolve(__dirname, '../../../app/javascript/assets/stylesheets/modules/_colors.scss'),
            //      //path.resolve(__dirname, '../../../app/javascript/assets/stylesheets/modules/_grid.scss'),
            //      //path.resolve(__dirname, '../../../app/javascript/assets/stylesheets/modules/_mixins.scss'),
            //    ],
            //  },
            //},
          ],
        },
        postcss: [
          require('postcss-import'),
          require('postcss-cssnext'),
          require('autoprefixer')({ grid: true })
        ],
      },
    },
  ],
};

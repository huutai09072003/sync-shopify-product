const { environment } = require("@rails/webpacker");
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')

const customConfig = require("./alias");

environment.config.merge(customConfig);
environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
environment.loaders.append('css', {
  test: /\.css$/,
  use: ['style-loader', 'css-loader'],
});

module.exports = environment;

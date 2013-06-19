prefix = './lib'
prefix = './src'  if /.coffee$/.test module.filename

module.exports = require "#{prefix}/plugin"

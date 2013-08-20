
config = require('../config')['mongo'][process.env.NODE_ENV or "development"]

mongoose = require('mongoose')

connectStr = config.db_prefix + '://'+config.host+'/'+config.db_database
console.log connectStr

DB = mongoose.createConnection connectStr
DB.on 'error', (err) ->
  console.log 'err:#{err}'
  DB.close()

module.exports = DB

process.env.NODE_ENV ?= 'development'


module.exports =
  port: 3001
  sso: true
  keys:
    staging: "VpAxFUIkWuUoqj8sWG86JmosFfKVmUbG"
    production: "sV1wqylVOQfSZjV7v1K2p30iSOq7kVlt"
    
  mongo:
    development :
      host:'localhost'
      db_prefix: 'mongodb'
      db_port: '27017'
      db_database: 'authenticate'
    staging :
      host:'localhost'
      db_prefix: 'mongodb'
      db_port: '27017'
      db_database: 'authenticate'
    production :
      host:'localhost'
      db_prefix: 'mongodb'
      db_port: '27017'
      db_database: 'authenticate'
      
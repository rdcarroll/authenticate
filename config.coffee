
process.env.NODE_ENV ?= 'development'


module.exports =
  port: process.env.PORT or 8080
  sso: true
  keys:
    staging: "VpAxFUIkWuUoqj8sWG86JmosFfKVmUbG"
    production: "sV1wqylVOQfSZjV7v1K2p30iSOq7kVlt"
    
  mongo:
    development :
      host:'localhost'
      port: '3000'
      db_prefix: 'mongodb'
      db_port: '27017'
      db_database: 'authenticate'
    staging :
      host:'localhost'
      port: '3000'
      db_prefix: 'mongodb'
      db_port: '27017'
      db_database: 'authenticate'
    production :
      host:'localhost'
      port: '3001'
      db_prefix: 'mongodb'
      db_port: '27017'
      db_database: 'authenticate'
      
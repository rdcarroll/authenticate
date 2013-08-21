
process.env.NODE_ENV ?= 'development'


module.exports =
  port: process.env.PORT or 8080
  sso: true
  keys:
    staging: "7ZyvspoRKyiulq7o2iGGwiaib5Fcy3ch"
    production: ""
    



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
      host:'nodejitsu:347fe515b3fad7ea90d66e57bb3406f4@alex.mongohq.com'
      port: '10020'
      db_prefix: 'mongodb'
      db_port: '27017'
      db_database: 'nodejitsudb408663363097'
      
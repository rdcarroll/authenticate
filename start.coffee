restify = require "restify"
config = require './config'
authMiddleware = require './lib/authMiddleware'
appnetMiddleware = require './lib/appnetMiddleware'

User = require './models/User'
Network = require './models/Network'
Application = require './models/Application'

Chatter = require './networks/chatter'
Box = require './networks/box'

server = restify.createServer name:'authenticate'

server.use restify.fullResponse()
server.use restify.bodyParser()
server.use restify.queryParser()
server.use authMiddleware if config.sso


server.get '/users', User.ReadAll
server.post '/users', User.Create
server.get '/users/:id', User.Read
server.put '/users/:id', User.Update 
server.del '/users/:id', User.Delete

server.get '/networks', Network.ReadAll
server.post '/networks', Network.Create
server.get '/networks/:id', Network.Read
server.put '/networks/:id', Network.Update 
server.del '/networks/:id', Network.Delete

server.get '/applications', Application.ReadAll
server.post '/applications', Application.Create
server.get '/applications/:id', Application.Read
server.put '/applications/:id', Application.Update 
server.del '/applications/:id', Application.Delete


server.use appnetMiddleware

server.get '/chatter/check', Chatter.check
server.get '/chatter/auth', Chatter.auth
server.get '/chatter/refresh', Chatter.refresh
server.get '/chatter/api/.*', Chatter.api

server.get '/box/check', Box.check
server.get '/box/auth', Box.auth
server.get '/box/refresh', Box.refresh
server.get '/box/api/.*', Box.api


server.listen config.port, ->
  console.log '%s listening at %s', server.name, server.url
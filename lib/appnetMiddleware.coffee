util = require '../lib/util'
eh = require '../lib/errors'

NetworkSchema = require '../schemas/Network'
UserSchema = require '../schemas/User'
ApplicationSchema = require '../schemas/Application'

module.exports = (req, res, next) ->

  #check for host (app name)
  host = req.headers['x-app-name']
  return next new Error "Header missing (x-app-name)" unless host?
  
  #locate the appropriate network metadata
  reg = /^\/([^\/]+)\/.*$/i
  m = reg.exec req.getPath()
  if m
    nw = m[1].toLowerCase()
    opts =
      query : {Name:{ $regex : new RegExp(nw,"i") }}
    util.read "Network", opts, NetworkSchema, (err, ndoc, count) ->
      return eh res, err if err? and err.statusCode isnt 404
      return eh res, new Error "Network Not found" unless ndoc?
      # console.log ndoc
      
      #locate the host metadata
      opts =
        query : { Name:host, Network:ndoc.get('_id') }
      util.read "Application", opts, ApplicationSchema, (err, adoc, count) ->
        return eh res, err if err? and err.statusCode isnt 404
        return next new Error "App Not found" unless adoc?
        # console.log adoc
        
        #locate the user information for the host and network
        opts = 
          query : {Username:req.user.bun, Network : ndoc.get('_id'), Application : adoc.get('_id')}
        util.read "User", opts, UserSchema, (err, udoc, count) ->
          return eh res, err if err? and err.statusCode isnt 404
          # console.log udoc
          
          req.network = ndoc
          req.application = adoc
          req.userjoin = udoc          
          
          next()  
    
  else return next new Error "Network Not Found in URL"
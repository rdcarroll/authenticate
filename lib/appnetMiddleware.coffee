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
  nw = req.getPath().split '/'
  if nw[0]? then nw = nw[0].toLowerCase().charAt(0).toUpperCase() else return next new Error "Network Not Found in URL"
  
  util.read "Network", {Name:nw}, NetworkSchema, (err, ndoc, count) ->
    return eh res, err if err?
    return next new Error "Network Not found" unless ndoc?
    # console.log ndoc
    
    #locate the host metadata
    util.read "Application", {Name:host}, ApplicationSchema, (err, adoc, count) ->
      return eh res, err if err?
      return next new Error "App Not found" unless adoc?
      # console.log adoc
      
      #locate the user information for the host and network
      opt = {Username:req.user.bun, Network : ndoc.get('_id'), Application : adoc.get('_id')}
      util.read "User", opt, UserSchema, (err, udoc, count) ->
        return eh res, err if err? and err.statusCode isnt 404
        # console.log udoc
        
        req.network = ndoc
        req.application = adoc
        req.userjoin = udoc
        
        
        next()
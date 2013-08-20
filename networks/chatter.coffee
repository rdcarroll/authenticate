request = require 'request'
util = require '../lib/util'
eh = require '../lib/errors'

NetworkSchema = require '../schemas/Network'
UserSchema = require '../schemas/User'
ApplicationSchema = require '../schemas/Application'

Chatter =
  check : (req, res, next) ->
    #create a user entry for host and network if one was not found
    unless req.userjoin?
      body =
        Username : req.user.bun
        Network : req.network.get('_id')
        Application : req.application('_id')
        
      util.create "User", {}, body, UserSchema, (err, doc) ->
        return eh res, err if err?
        return next new Error "Error creating new user/app/network transaction" unless doc?
        #must go thru oauth if no access token or refresh token exists  
        Chatter.redirectURL  req.network, req.application, req.userjoin, (err, result) -> 
          return eh res, err if err?
          res.send 200,
            "oatuh_complete" : false
            "redirect" : true
            "redirect_uri" : result  
    
    else unless req.userjoin.AccessToken?
      #try to use the refresh token if there is one
      if req.userjoin.RefreshToken?
        Chatter.refresh req.network, req.application, req.userjoin, (err, result) ->
          return eh res, err if err?
          res.send 200,
            "oatuh_complete" : true    
      #must go thru oauth if no access token or refresh token exists            
      else
        Chatter.redirectURL  req.network, req.application, req.userjoin, (err, response) -> 
          return eh res, err if err?
          res.send 200,
            "oatuh_complete" : false
            "redirect" : true
            "redirect_uri" : response  
    else
      res.send 200,
        "oatuh_complete" : true
    
  auth : (req, res, next) ->
    #check for token
    token = req.get('oauth_token')
    return next new Error "oauth token missing" unless token?
    
    url = "client_id=#{req.application.AppKey}"
    url += "&redirect_uri=#{req.application.RedirectUrl}"
    url += "&client_secret=#{req.application.AppSecret}"
    url += "&grant_type=#{req.network.grant_type}"
    url += "&code=#{token}"
    
    options=
      url : req.network.start_base_url + req.network.access_path
      method : "POST"
      headers: {'content-type' : 'application/x-www-form-urlencoded'}
      body : url
    request options (err, response, body) ->
      return eh res, err if err?
      return next new Error "network auth error: body not found" unless body?
      try
        body = JSON.parse(body)
        if body.access_token?  
          user = req.userjoin       
          user.access_token = body.access_token
          user.refresh_token = body.refresh_token
          user.issued_at = body.issued_at
          user.save (err) ->
            return eh res, err if err?
            res.send 200,
              "oatuh_complete" : true
            
      catch e
        return next new Error "network auth error: request failed"
      
      
  refresh : (req, res, next) ->
    
    url = "client_id=#{req.application.AppKey}"
    url += "&client_secret=#{req.application.AppSecret}"
    url += "&grant_type=#{req.network.grant_type}"
    url += "&refresh_token=#{req.userjoin.RefreshToken}"
    
    options=
      url : req.network.start_base_url + req.network.access_path
      method : "POST"
      headers: {'content-type' : 'application/x-www-form-urlencoded'}
      body : url
    request options (err, response, body) ->
      return eh res, err if err?
      return next new Error "network refresh error: body not found" unless body?
      try
        body = JSON.parse(body)
        if body.access_token?   
          user = req.userjoin       
          user.access_token = body.access_token
          user.save (err) ->
            return eh res, err if err?
            res.send 200,
              "oatuh_complete" : true
            
      catch e
        return next new Error "network refresh error: request failed"
    
    
    
  api : (req, res, next) ->
    uri = req.url.replace /\/chatter\/api\//i, ""
    url = "#{req.network.start_base_url}#{req.network.feed_url}" + uri
    options=
      url : url
      body : JSON.stringify(req.body)
      method : req.route.method
      headers : {'Authorization': 'Bearer ' + req.network.access_token }
    request options, (err, response, body) ->
      return eh res, err if err?
      return next new Error "network request error: body not found" unless body?
      if body.errorCode? and body.errorCode is "INVALID_SESSION_ID"
        a = "do stuff"
      else
        res.send 200,
          "body" : body
    
  redirectURL : (network, application, user, cb) ->
    url = "#{network.start_base_url}#{network.oauth_path}"
    url += "?client_id=#{application.AppKey}"
    url += "&redirect_uri=#{application.RedirectUrl}"
    url += "&response_type=#{network.response_type}"
    url += "&type=#{network.type}"

    cb null, url




module.exports = Chatter
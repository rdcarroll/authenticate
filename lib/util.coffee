restify = require "restify" #for error handling messages
db = require './database'
mongoose = require 'mongoose'

# extend = require 'xtend' #extend objects

Util =            
      
  Options : (q) ->
    start : q.start or 0
    limit : q.limit or 100
    
  defineSchemas : (arr) ->
    for a in arr[0].split ' '
      db.model a, require '../schemas/'+a
      
  reduceSet : (red, doc) ->
    _doc = doc
    for k,v of red
      _doc = _doc.get k
      _doc = _doc.id v if v?
    return _doc
    
  readAll : (cName, opts, schema, cb) ->
    try
      model = if typeof cName is 'string' then db.model cName, schema else cName
      # model.count opts.query, (err, count) =>
        # if err then cb new restify.InvalidArgumentError(JSON.stringify(err.errors))
      @defineSchemas opts.populate if opts.populate?
      q = model.find opts.query        
      q.select opts.select if opts.select?
      q.populate opts.populate... if opts.populate?
      q.exec (err, doc) =>
        if err then cb new restify.InvalidArgumentError(JSON.stringify(err.errors))
        else
        
          # doc = @reduceSet(opts.reduce, doc) if opts.reduce?
          cb null, doc, doc.length
    catch e
      cb new restify.InternalError('Error Reading from Database') 
          
  create : (cName, opts, body, schema, cb) ->
    try
      model = db.model cName, schema
          
      model.create body, (err, doc) =>
        if err then cb new restify.InvalidArgumentError(JSON.stringify(err.errors)) 
        else
          doc.populate opts.populate... if opts.populate?
          cb null, doc, 1
    catch e
      cb new restify.InternalError('Error Reading from Database') 
        
  read : (cName, opts, schema, cb) ->
    try
      model = db.model cName, schema      
      # model.count opts.query, (err, count) =>
        # if err then cb new restify.InvalidArgumentError(JSON.stringify(err.errors))
      @defineSchemas opts.populate if opts.populate?
      q = model.findOne opts.query        
      q.select opts.select if opts.select?
      q.populate opts.populate... if opts.populate?
      q.exec (err, doc) =>
        if err then cb new restify.InvalidArgumentError(JSON.stringify(err.errors))
        else unless doc? then cb new restify.ResourceNotFoundError('Query returned no content.')
        else cb null, doc, doc.length
    catch e
      cb new restify.InternalError('Error Reading from Database') 
          
  update : (cName, opts, body, schema, cb) ->
    try
      model = db.model cName, schema      
      model.findOne opts.query, (err, doc) ->
        if err then cb new restify.InvalidArgumentError(JSON.stringify(err.errors))
        delete body._id
        doc.set body
        doc.save (err, doc) ->
          if err then cb new restify.InvalidArgumentError(JSON.stringify(err.errors))
          cb null, doc, 1
    catch e
      cb new restify.InternalError('Error Reading from Database')
            
        
              
  remove : (cName, opts, schema, cb) ->
    try
      model = db.model cName, schema
      q = model.findOne opts.query
      q.remove (err) ->
        if err then cb new restify.InvalidArgumentError(JSON.stringify(err.errors))
        else 
          cb null, {id:opts.query._id}, 1
    catch e
      cb new restify.InternalError('Error Reading from Database')
  

module.exports = Util

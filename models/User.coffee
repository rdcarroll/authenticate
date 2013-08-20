restify = require "restify" #for error handling messages
util = require '../lib/util'
eh = require '../lib/errors'

DOCNAME = 'User'
Schema = require '../schemas/' + DOCNAME

_select = null
_populate = null

module.exports = 
  ReadAll : (req, res, next) ->
    opts =
      query : {}
      select : _select
      populate : _populate
      wrap : util.Options(req.query)
    
    util.readAll DOCNAME, opts, Schema, (err, docs, count) =>
      return eh res, err if err?
      return next new Error "Not found" unless docs?
      
      res.send 200,
        start: opts.wrap.start
        limit: opts.wrap.limit
        totalcount: count
        items: docs

      
  Create : (req, res, next) ->
    opts =
      select : _select
      populate : _populate
    util.create DOCNAME, opts, req.body, Schema, (err, doc, count) ->
      return eh res, err if err?
      return next new Error "Not found" unless doc?
      
      res.send 200,
        success : true
        totalcount: count
        items: doc

  Read : (req, res, next) ->
    opts =
      query : {_id:req.params.id}
      select : _select
      populate : _populate
      wrap : util.Options(req.query)
    util.read DOCNAME, opts, Schema, (err, doc, count) =>
      return eh res, err if err?
      return next new Error "Not found" unless doc?
      
      res.send 200,
        start: opts.wrap.start
        limit: opts.wrap.limit
        totalcount: count
        items: [doc]
        
  Update : (req, res, next) ->
    opts =
      query : {_id:req.params.id}
      select : _select
      populate : _populate
      wrap : util.Options(req.query)
    util.update DOCNAME, opts, req.body, Schema, (err, doc, count) =>
      return eh res, err if err?
      return next new Error "Not found" unless doc?
      
      res.send 200,
        start: opts.wrap.start
        limit: opts.wrap.limit
        totalcount: count
        items: [doc]

  Delete : (req, res, next) ->
    opts =
      query : {_id:req.params.id}
      wrap : util.Options(req.query)
    util.remove DOCNAME, opts, Schema, (err, doc) ->
      return eh res, err if err?
      return next new Error "Not found" unless doc?
      
      res.send 200,
        success : true
        id : doc.id 
  

    

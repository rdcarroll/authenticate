request = require 'request'
config = require '../config'

module.exports = (req, res, next) ->
  token = req.headers["x-mypsn-accesstoken"]
  return next new Error "Invalid token" unless token?

  opt =
    url: "https://api-staging.becpsn.com/identity/"
    qs:
      format: "json"
    headers:
      "Authorization": token
      "X-MyPsn-AppKey": config.keys.staging

  request opt, (err, res, body) ->
    return next err if err?
    return next new Error "Invalid token" if res.statusCode is 403
    return next new Error "Invalid body from SSO" unless body?
    try
      body = JSON.parse body
    catch e
      return next new Error "Invalid body from SSO"
    return next new Error "Invalid body from SSO" unless Array.isArray body

    req.sso = {}
    for svc in body
      req.sso[svc.ResourceName] = svc.Item

    if req.sso.Apigee?["X-myPSN-UserAttributes"]?
      req.sso.UserAttributes = JSON.parse(req.sso.Apigee["X-myPSN-UserAttributes"]).access_token
    
    attrs = req.sso.UserAttributes
    if attrs?
      req.user =
        bun: attrs.BechtelUserName?.trim()
        employeeNumber: attrs.BechtelEmployeeNumber?.trim()
        name:
          first: attrs.FirstName?.trim()
          last: attrs.LastName?.trim()
        email: attrs.BechtelEmailAddress?.trim()
        employee: (attrs.IsBechtelEmployee isnt '0')
        domain: attrs.BechtelDomain?.trim()
        title: attrs.Title?.trim()

    return next new Error "Unauthorized" unless req.user?
    next()
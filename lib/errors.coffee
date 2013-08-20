module.exports = (res, err, code=500) ->
  err = new Error err if typeof err is 'string'
  code = err.statusCode if err.statusCode?
  try
    err = JSON.stringify err
  catch e
    err =
      name: err.name
      message: err.message
      key: err.key
  res.send code, err
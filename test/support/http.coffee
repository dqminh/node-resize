# Based on https://github.com/visionmedia/express/blob/master/test/support/http.js
EventEmitter = require('events').EventEmitter
http = require 'http'
methods = require('express').router.methods

class Request extends EventEmitter
  # create a new Request instance. A Request instance allow user to perform
  # http request to the application which is very useful in test
  #
  # - app: an instance of express.createServer
  constructor: (@app) ->
    @data = []
    @headers = {}
    @app.listen 0, =>
      @address = @app.address()
      @listening = true

  request: (@method, @path) ->
    return this

  setHeader: (field, value) ->
    @headers[field] = value
    this

  write: (data) ->
    @data.push data
    this

  end: (fn) ->
    if @listening
      params = 
        method: @method,
        port: @address.port
        host: @address.address
        path: @path
        headers: @headers
      request = http.request params
      @data.forEach (chunk) -> request.write chunk
      request.on 'response', (response) ->
        buf = ''
        response.on 'data', (chunk) -> buf += chunk
        response.on 'end', ->
          response.body = buf
          fn(response)
      request.end()
    else
      @app.on 'listening', => @end(fn)
    this

# define convenience HTTP methods
methods.forEach (method) ->
  Request::[method] = (path) -> @request(method, path)

# easier access Request instance
request = (app) -> new Request(app)

module.exports = request

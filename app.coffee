http        = require 'http'
url         = require 'url'
mime        = require 'mime'
ResizeImage = require './lib/resize_image'
express     = require 'express'
app = module.exports = express()
test = app.get('env') == "test"

app.use express.favicon(__dirname + '/favicon.ico', maxAge: 2592000000)
app.use app.router

getFileOptions = (path) -> url.parse(new Buffer(path, 'base64').toString())

# Setting Cache Control
# The response should have
# - Etag: current time in milliseconds
# - Last-Modified: current time in UTC string
# - Cache-Control: cached the response for 1 year
setCacheControl = (request, response, next) ->
  one_year_in_seconds = 365 * 24 * 60 * 60
  response.header 'ETag', new Date().getTime()
  response.header 'Last-Modified', new Date().toUTCString()
  response.header 'Cache-Control', "public; max-age=#{one_year_in_seconds}"
  response.header 'Pragma', 'cache'
  next()

# Set Content-Type of the response
setContentType = (options, response) ->
  response.header 'Content-Type', mime.lookup options.path

# Error handling. Just output an empty image response with 400 status code
error = (err, request, response, next) ->
  response.setHeader "Content-Type", "image/jpeg"
  response.send 400, ""
app.use error

# Pipe out the image without any modification
renderImage = (request, response, next) ->
  options = getFileOptions(request.params.path)
  setContentType options, response
  fileRequest = http.request options, (image) -> image.pipe response
  fileRequest.end()

# Resize the image to the user desired width/height
resize = (request, response, next) ->
  [width, height] = (+dimension for dimension in request.params.size.split('x', 2))
  options = getFileOptions request.params.path
  setContentType options, response
  console.log "resize width: #{width}, height: #{height} for #{options.host}/#{options.path}" if !test

  if width > 0 && height > 0
    width = 2000 if width > 2000
    height = 2000 if height > 2000

    fileRequest = http.request options, (fileResponse) ->
      resizeImage = new ResizeImage fileResponse, response
      resizeImage.run width, height
    fileRequest.end()
  else
    throw new Error("invalid request: #{request.params}")

app.get '/:path/size/:size', setCacheControl, resize
app.get '/:path', setCacheControl, renderImage

module.exports = app

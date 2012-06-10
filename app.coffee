http = require 'http'
url = require 'url'
gm = require 'gm'
express = require 'express'

app = express.createServer()
im = gm.subClass imageMagick: true

app.use express.favicon(__dirname + '/favicon.ico', maxAge: 2592000000)

getFileOptions = (path) ->
  url.parse(new Buffer(path, 'base64').toString())

setCacheControl = (response) ->
  one_day_in_seconds = 86400
  response.header 'ETag', new Date().getTime()
  response.header 'Last-Modified', new Date().toUTCString()
  response.header 'Cache-Control', "public; max-age=#{one_day_in_seconds}"

render_image = (request, response) ->
  setCacheControl response
  fileRequest = http.request getFileOptions(request.params.path), (fileResponse) ->
    fileResponse.pipe response

  fileRequest.end()

resize = (request, response) ->
  [width, height] = (+dimension for dimension in request.params.size.split('x', 2))
  options = getFileOptions request.params.path
  console.log "resize width: #{width}, height: #{height} for #{options.host}/#{options.path}"
  width = 2000 if width > 2000
  height = 2000 if height > 2000

  setCacheControl response

  response.on 'data', (data) ->
    console.log data

  fileRequest = http.request options, (fileResponse) ->
    im(fileResponse).size bufferStream: true, (err, size) ->
      [cols, rows] = [size.width, size.height]
      if width != cols || height != rows
        scale = Math.max.apply Math, [width/cols, height/rows]
        [cols, rows] = (Math.round(scale * (x + 0.5)) for x in [cols, rows])

      this
        .gravity('Center')
        .background('rgba(255,255,255,0.0)')
        .resize(cols, rows)
        .noProfile()
      this.extent(width, height) if cols != width || rows != height
      this.stream (err, stdout, stderr) ->
        stdout.pipe response

  fileRequest.on 'error', () -> console.log "errror"
  fileRequest.end()

app.get '/:path/size/:size', resize
app.get '/:path', render_image

module.exports = app

#port = process.env.PORT || 3000
#app.listen port, -> console.log "Listening on #{port}"

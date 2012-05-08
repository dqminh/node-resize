http = require 'http'
url = require 'url'
gm = require 'gm'
app = require('express').createServer()
im = gm.subClass imageMagick: true

getFileOptions = (path) ->
  parsedPath = url.parse(new Buffer(path, 'base64').toString())
  fileOptions =
    host: parsedPath.hostname
    port: parsedPath.port
    path: parsedPath.pathname
    method: 'GET'

setCacheControl = (response) ->
  one_day_in_seconds = 86400
  response.header 'Cache-Control', "public; max-age=#{one_day_in_seconds}"

render_image = (request, response) ->
  setCacheControl response
  fileRequest = http.request getFileOptions(request.params.path), (fileResponse) ->
    fileResponse.pipe response

  fileRequest.end()

resize = (request, response) ->
  [width, height] = (+dimension for dimension in request.params.size.split('x', 2))
  
  width = 2000 if width > 2000
  height = 2000 if height > 2000

  setCacheControl response

  fileRequest = http.request getFileOptions(request.params.path), (fileResponse) ->
    im(fileResponse).size bufferStream: true, (err, size) ->
      [cols, rows] = [size.width, size.height]
      if width != cols || height != rows
        scale = Math.max.apply Math, [width/cols, height/rows]
        [cols, rows] = (Math.round(scale * (x + 0.5)) for x in [cols, rows])
        this.resize cols, rows

      this
        .gravity('Center')
        .background('rgba(255,255,255,0.0)')
      this.extent(width, height) if cols != width || rows != height
      this.stream (err, stdout, stderr) ->
        stdout.pipe response

  fileRequest.end()

app.get '/:path/size/:size', resize
app.get '/:path', render_image

port = process.env.PORT || 3000
app.listen port, ->
  console.log "Listening on #{port}"

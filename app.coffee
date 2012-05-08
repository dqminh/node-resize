http = require 'http'
url = require 'url'
gm = require 'gm'
app = require('express').createServer()
im = gm.subClass imageMagick: true

resize = (request, response) ->
  parsedPath = url.parse(new Buffer(request.params.path, 'base64').toString())
  [width, height] = (+dimension for dimension in request.params.size.split('x', 2))

  fileOptions =
    host: parsedPath.hostname
    port: parsedPath.port
    path: parsedPath.pathname
    method: 'GET'

  one_day_in_seconds = 86400
  response.header 'Cache-Control', "public; max-age=#{one_day_in_seconds}"

  fileRequest = http.request fileOptions, (fileResponse) ->
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

port = process.env.PORT || 3000
app.listen port, ->
  console.log "Listening on #{port}"

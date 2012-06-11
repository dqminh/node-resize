gm = require 'gm'
im = gm.subClass imageMagick: true

class ResizeImage
  constructor: (@file, @response) ->
  run: (width, height) =>
    response = @response
    im(@file).size bufferStream: true, (err, size) ->
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
      this.stream (err, stdout, stderr) => stdout.pipe response


module.exports = ResizeImage

request = require('./support/http')
app = require('../app')
sampleImage = "aHR0cDovL3d3dy5nb29nbGUuY29tL2ludGwvZW5fQUxML2ltYWdlcy9sb2dvcy9pbWFnZXNfbG9nb19sZy5naWY="

describe "Application", ->
  it 'allows user to resize image', (done) ->
    request(app).get("/#{sampleImage}").end (response) ->
      response.statusCode.should.equal 200
      response.body.length.should.be.above 0
      done()

  it 'allows user to stream original image', (done) ->
    request(app).get("/#{sampleImage}/size/50x50").end (response) ->
      response.statusCode.should.equal 200
      response.body.length.should.be.above 0
      done()

  it 'does not allow invalid size', (done) ->
    request(app).get("/#{sampleImage}/size/(null)").end (response) ->
      response.statusCode.should.equal 400
      response.headers['content-type'].should.be.equal "image/jpeg"
      response.body.should.be.equal ""
      done()

  it 'sets ETag of the response', (done) ->
    request(app).get("/#{sampleImage}").end (response) ->
      response.headers.etag.should.be.above 0
      done()
    
  it 'sets Last-Modified of the response', (done) ->
    request(app).get("/#{sampleImage}").end (response) ->
      response.headers['last-modified'].length.should.be.above 0
      done()

  it 'sets Cache-Control of the response to 1 year', (done) ->
    request(app).get("/#{sampleImage}").end (response) ->
      response.headers['cache-control'].should.be.equal "public; max-age=31536000"
      done()

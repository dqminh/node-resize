request = require('./support/http')
app = require('../app')
sampleImage = "aHR0cDovL3d3dy5nb29nbGUuY29tL2ludGwvZW5fQUxML2ltYWdlcy9sb2dvcy9pbWFnZXNfbG9nb19sZy5naWY="

describe "Application", ->
  it 'allows user to resize image', ->
    request(app).get("/#{sampleImage}").end (response) ->
      response.status.should.equal 200
      done()

  it 'allows user to stream original image', ->
    request(app).get("/#{sampleImage}/size/50x50").end (response) ->
      response.status.should.equal 200
      done()

  it 'does not allow invalid size', ->
    request(app).get("/#{sampleImage}/size/(null").end (response) ->
      response.status.should.equal 200
      done()

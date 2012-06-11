app = require '../app'

describe "Routes", ->

  it 'has routes to resize image', ->
    app.routes.get[0].path.should.be.equal "/:path/size/:size"

  it 'has routes to render original image', ->
    app.routes.get[1].path.should.be.equal "/:path"

  

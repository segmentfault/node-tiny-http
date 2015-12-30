HttpServer = require 'http'
Url = require 'url'
Result = require './result'
Router = require './router'

class Http
    constructor: ->
        @resultInstance = new Result
        @routerInstance = new Router


    # listen port
    listen: (options) ->
        http = HttpServer.createServer @routerInstance.handler @resultInstance.result, options
        
        if options.sock?
            http.listen options.sock
        else
            options.port = options.port or 8888
            options.host = options.host or 'localhost'
            http.listen options.port, options.host


    # register result
    result: (args...) ->
        @resultInstance.register.apply @resultInstance, args


    # use default interceptor
    use: (args...) ->
        @routerInstance.use.apply @routerInstance, args

    
    # on method
    on: (pattern, fn, method = null) ->
        @routerInstance.register method, pattern, fn

    
    # get method
    get: (pattern, fn) ->
        @routerInstance.register 'GET', pattern, fn

    
    # post method
    post: (pattern, fn) ->
        @routerInstance.register 'POST', pattern, fn

    
    # static file method
    assets: (path, dir) ->
        @routerInstance.register 'GET', (path.replace /\/+$/g, '') + '/%path', (done) ->
            done 'file', dir + '/' + ((@request.get 'path').replace /\.{2,}/g, '')
        .raw()


module.exports = Http


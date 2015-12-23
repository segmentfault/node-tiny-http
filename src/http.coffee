Http = require 'http'
Url = require 'url'
Result = require './result'
Router = require './router'

module.exports =
    start: (options) ->
        http = Http.createServer Router.handler Result.result, options
        
        if options.sock?
            http.listen options.sock
        else
            options.port = options.port or 8888
            options.host = options.host or 'localhost'
            http.listen options.port, options.host

    
    # register result
    result: Result.register

    
    # on method
    on: (pattern, fn...) ->
        Router.register null, pattern, fn

    
    # get method
    get: (pattern, fn...) ->
        Router.register 'GET', pattern, fn

    
    # post method
    post: (pattern, fn...) ->
        Router.register 'POST', pattern, fn

    
    # static file method
    assets: (path, dir) ->
        Router.register 'GET', (path.replace /\/+$/g, '') + '/%path', [->
            @result.file dir + '/' + ((@request.get 'path').replace /\.{2,}/g, '')
        ]

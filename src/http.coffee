Http = require 'http'
Url = require 'url'
Result = require './result'
Router = require './router'

module.exports =
    start: (port = 80, host = 'localhost') ->
        http = Http.createServer Router.handler Result.results
        http.listen port, host

    rule: Router.registerRule

    result: Result.register

    # on method
    on: (pattern, fn, method = null) ->
        Router.register method, pattern, fn

    # get method
    get: (pattern, fn) ->
        Router.register 'GET', pattern, fn

    # post method
    post: (pattern, fn) ->
        Router.register 'POST', pattern, fn

    # static file method
    assets: (path, dir) ->
        Router.register 'GET', (path.replace /\/+$/g, '') + '/%path', (request) ->
            @file dir + '/' + ((request.get 'path').replace /\.{2,}/g, '')


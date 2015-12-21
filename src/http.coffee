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
        Router.register 'get', pattern, fn

    # post method
    post: (pattern, fn) ->
        Router.register 'post', pattern, fn

    # static file method
    assets: (path, dir) ->
        Router.register 'get', (path.replace /\/+$/g, '') + '/%path', (params) ->
            @file dir + '/' + (params.path.replace /\.{2,}/g, '')


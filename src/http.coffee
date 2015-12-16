Http = require 'http'
Fs = require 'fs'
Mime = require 'mime'
Url = require 'url'

# results map
results = {}

# routes map
routes = {}

# rules map
rules = {}

# register response method
resultRegister = (name, fn) ->
    results[name] = (args...) ->
        (req, res, params) ->
            fn.apply {req, res, params}, args


# some default result
# handler static file
resultRegister 'file', (file) ->
    Fs.access file, Fs.R_OK, (err) =>
        if err?
            @res.writeHead 404, 'Content-Type: text/html; charset=utf-8'
            return @res.end 'File not found.'

        mime = Mime.lookup file
        @res.writeHead 200, 'Content-Type: ' + mime + '; charset=utf-8'

        stream = Fs.createReadStream file
        stream.pipe @res


# handler 404
resultRegister 'notFound', ->
    @res.writeHead 404, 'Content-Type: text/html; charset=utf-8'
    return @res.end 'File not found.'


# handler json data
resultRegister 'json', (data) ->
    @res.writeHead 200, 'Content-Type: application/json; charset=utf-8'
    @res.end JSON.stringify data


# handler html data
resultRegister 'content', (content, type = 'text/html') ->
    @res.writeHead 200, 'Content-Type: ' + type + '; charset=utf-8'
    @res.end content


# create match uri pattern
routerMatch = (method, pattern) ->
    keys = []
    currentRules = []

    # split rules
    parts = pattern.split ' '

    if parts.length > 1
        currentRules = parts[0].split ';'
        pattern = parts[1]


    # replace as regex
    pattern = pattern.replace /(:|%)([_a-z0-9-]+)/i, (m, prefix, name) ->
        keys.push name
        if prefix == ':' then '([^\\/]+)' else '(.+)'

    r = new RegExp "^#{pattern}$", 'g'

    [currentRules, \
    (requestMethod, uri, params) ->
        return no if method? and requestMethod != method

        result = r.exec uri
        r.lastIndex = 0

        if result?
            # inject params
            for val, i in result
                continue if i == 0
                params[keys[i - 1]] = val
            return yes

        # not matched
        no
    ]


# register routes
routerRegister = (method, pattern, fn) ->
    [currentRules, tester] = routerMatch method, pattern
    routes[pattern] = [tester, currentRules, fn]


# handler for http
routerHandler = (req, res) ->
    parts = Url.parse req.url, yes
    uri = if parts.pathname? then parts.pathname else '/'
    params = parts.query
    result = null

    for pattern, def of routes
        [tester, currentRules, fn] = def

        # deny not matched
        continue if not tester req.method, uri, params

        for rule in currentRules
            result = rules[rule].call results, params if rules[rule]?
            break if result instanceof Function

        result = fn.call results, params if result not instanceof Function
        break

    result = results.notFound() if not result?
    result.call null, req, res, params


module.exports =
    rule: (name, fn) ->
        rules[name] = fn

    result: resultRegister

    start: (port = 80, host = 'localhost') ->
        http = Http.createServer routerHandler
        http.listen port, host

    # on method
    on: (pattern, fn, method = null) ->
        routerRegister method, pattern, fn

    # get method
    get: (pattern, fn) ->
        routerRegister 'get', pattern, fn

    # post method
    post: (pattern, fn) ->
        routerRegister 'post', pattern, fn

    # static file method
    assets: (path, dir) ->
        routerRegister 'get', (path.replace /\/+$/g, '') + '/%path', (params) ->
            @file dir + '/' + (params.path.replace /\.{2,}/g, '')


Form = require 'formidable'
Url = require 'url'
Cookie = require 'cookie'
QueryString = require 'querystring'


class Request

    options = {}

    mergeParams = (source, target) ->
        for k, v of target
            source[k] = v


    constructor: (@req, opt, cb) ->
        parts = Url.parse @req.url, yes
        options = opt

        @method = @req.method.toUpperCase()
        @uri = parts.href
        @path = if parts.pathname? then parts.pathname else '/'
        @port = @req.socket.remotePort
        @agent = @header 'user-agent', ''

        # detect host
        host = @header 'host', ''
        matched = host.match /^\s*([_0-9a-z-\.]+)/
        @host = if matched then matched[1] else null
        
        @$cookies = Cookie.parse @header 'cookie', ''
        @$params = parts.query
        @$files = {}
        @$ip = null
        
        if @method is 'POST'
            form = new Form.IncomingForm

            form.parse @req, (err, fields, files) =>
                return cb @ if err?

                mergeParams @$params, fields
                @$files = files
                cb @
        else
            cb @


    ip: ->
        defaults = ['x-real-ip', 'x-forwarded-for', 'client-ip']

        if not @$ip?
            if options.ipHeader?
                @$ip = @header options.ipHeader, @req.socket.remoteAddress
            else
                for key in defaults
                    val = @header key

                    if val?
                        @$ip = val
                        break

                @$ip = @req.socket.remoteAddress

        @$ip


    header: (key, val = undefined) ->
        key = key.toLowerCase()
        if @req.headers[key] then @req.headers[key] else val

    
    cookie: (key, val = undefined) ->
        if @$cookies[key]? then @$cookies[key] else val


    is: (query) ->
        required = QueryString.parse query

        for k, v of required
            if v.length > 0
                return no if v != @get k
            else
                return no if (@get k) is undefined
        yes

    
    set: (key, val = null) ->
        if val == null and key instanceof Object
            mergeParams @$params, key
        else
            @$params[key] = val


    get: (key, defaults = undefined) ->
        if @$params[key]? then @$params[key] else defaults
    
    
    file: (key) ->
        if @$files[key]? then @$files[key] else undefined


module.exports = Request


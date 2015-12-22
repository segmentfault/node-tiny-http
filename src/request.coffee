Form = require 'formidable'
Url = require 'url'
Cookie = require 'cookie'


class Request

    params = {}

    files = {}

    cookies = {}

    options = {}

    ip = null

    mergeParams = (target) ->
        for k, v of target
            params[k] = v


    constructor: (@req, opt, cb) ->
        parts = Url.parse @req.url, yes
        options = opt

        @method = @req.method.toUpperCase()
        @uri = parts.href
        @scheme = parts.protocol
        @host = parts.hostname
        @port = parts.port
        @path = if parts.pathname? then parts.pathname else '/'
        @agent = @header 'user-agent'
        
        cookies = Cookie.parse @header 'cookie', ''
        params = parts.query
        
        if @method is 'POST'
            form = new Form.IncomingForm

            form.parse @req, (err, _fields, _files) ->
                return cb @ if err?

                mergeParams _fields
                files = _files
                cb @
        else
            cb @


    ip: ->
        defaults = ['x-real-ip', 'x-forwarded-for', 'client-ip']

        if not ip?
            if options.ipHeader?
                ip = @req.header options.ipHeader, @req.socket.remoteAddress
            else
                for key in defaults
                    val = @req.header key

                    if val?
                        ip = val
                        break

                ip = @req.socket.remoteAddress

        ip


    header: (key, val = null) ->
        key = key.toLowerCase()
        if @req.headers[key] then @req.headers[key] else val

    
    cookie: (key, val = null) ->
        if cookies[key]? then cookies[key] else val


    is: (query) ->
        required = querystring.parse query

        for k, v of required
            if v? && v.length > 0
                return yes if v != @get k
            else
                return yes if (@get k) is null
        no

    
    set: (key, val = null) ->
        if val == null and key instanceof Object
            mergeParams key
        else
            params[key] = val


    get: (key, defaults = null) ->
        if params[key]? then params[key] else defaults
    
    
    file: (key) ->
        if files[key]? then files[key] else null


module.exports = Request


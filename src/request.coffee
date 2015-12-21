Form = require 'formidable'
Url = require 'url'


class Request

    params = {}

    files = {}


    mergeParams = (target) ->
        for k, v of target
            params[k] = v


    constructor: (@req, cb) ->
        parts = Url.parse @req.url, yes

        @method = @req.method.toUpperCase()
        @uri = parts.href
        @scheme = parts.protocol
        @host = parts.hostname
        @port = parts.port
        @path = if parts.pathname? then parts.pathname else '/'
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


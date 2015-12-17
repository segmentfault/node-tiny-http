Form = require 'formidable'


class Request

    params = {}

    files = {}

    constructor: (@req, cb) ->
        parts = Url.parse @req.url, yes
        
        if @req.method is 'post'
            form = new Form.IncomingForm

            form.parse @req, (err, fields, files) ->
                return cb() if err?

    
    get: (key, defaults = null) ->
        if params[key]? then key else defaults


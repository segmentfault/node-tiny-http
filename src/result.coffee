Fs = require 'fs'
Mime = require 'mime'

# results map
results = {}

# register response method
register = (name, fn) ->
    results[name] = (args...) ->
        (req, res, params) ->
            fn.apply {req, res, params}, args


# some default result
# handler static file
register 'file', (file) ->
    Fs.access file, Fs.R_OK, (err) =>
        if err?
            @res.writeHead 404, 'Content-Type: text/html; charset=utf-8'
            return @res.end 'File not found.'

        mime = Mime.lookup file
        @res.writeHead 200, 'Content-Type: ' + mime + '; charset=utf-8'

        stream = Fs.createReadStream file
        stream.pipe @res


# handler 404
register 'notFound', ->
    @res.writeHead 404, 'Content-Type: text/html; charset=utf-8'
    return @res.end 'File not found.'


# handler json data
register 'json', (data) ->
    @res.writeHead 200, 'Content-Type: application/json; charset=utf-8'
    @res.end JSON.stringify data


# handler html data
register 'content', (content, type = 'text/html') ->
    @res.writeHead 200, 'Content-Type: ' + type + '; charset=utf-8'
    @res.end content

module.exports = { results, register }


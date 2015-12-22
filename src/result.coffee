Fs = require 'fs'
Mime = require 'mime'

# results map
results = {}

# register response method
register = (name, fn) ->
    results[name] = (args...) ->
        (request, response) ->
            fn.apply {request, response}, args


# some default result
# handler static file
register 'file', (file) ->
    Fs.access file, Fs.R_OK, (err) =>
        if err?
            return @response.status 200
                .header 'content-type', 'text/html; charset=utf-8'
                .content 'File not found.'

        mime = Mime.lookup file
        @response.content ->
                stream = Fs.createReadStream file
                stream.pipe @res


# blank content
register 'blank', ->
    @response.content ''


# redirect url
register 'redirect', (url, permanently = no) ->
    @response.status if permanently then 301 else 302
        .header 'location', url


# redirect to referer
register 'back', ->
    url = @request.header 'referer', '/'
    @response.status 302
        .header 'location', url


# handler 404
register 'notFound', ->
    @response.status 404
        .content 'File not found.'


# handler json data
register 'json', (data) ->
    @response.header 'content-type', 'application/json; charset=utf-8'
        .content JSON.stringify data


# handler html data
register 'content', (content, type = 'text/html') ->
    @response.header 'content-type', type + '; charset=utf-8'
        .content content


module.exports = { results, register }


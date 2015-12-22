Cookie = require 'cookie'
Status = require 'statuses'

class Response

    statusCode = 200

    headers =
        'content-type': 'text/html; charset=utf-8'

    cookies = []

    content = null

    options = {}


    constructor: (@res, opt) ->
        options = opt


    # set content
    content: (val) ->
        content = val
        @

    
    # set status code
    status: (code) ->
        statusCode = Status code
        @


    # set cookie
    cookie: (key, val, options) ->
        cookies.push Cookie.serialize key, val, options
        @


    # set header
    header: (key, val) ->
        key = key.toLowerCase()
        headers[key] = val
        @

    
    # respond
    respond: ->
        @res.statusCode = statusCode
        @res.statusMessage = Status[statusCode]

        
        for key, val of headers
            key = key.replace /(^|-)([a-z])/g, (m, a, b) ->
                a + b.toUpperCase()

            @res.setHeader key, val

        @res.setHeader 'Set-Cookie', cookies if cookies.length > 0
        
        if content instanceof Function
            content.apply @
        else
            @res.end content


module.exports = Response


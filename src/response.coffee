Cookie = require 'cookie'
Status = require 'statuses'
Zlib = require 'zlib'
Stream = require 'stream'


# make a monkey patch for original response object
patchOriginalResponse = (res) ->
    originalWrite = res.write
    res.bytes = 0

    res.write = (args...) ->
        buf = args[0]
        @bytes += buf.length

        originalWrite.apply @, args


class Response


    constructor: (@res, req, @options) ->

        @$statusCode = 200
        @$headers =
            'content-type': 'text/html; charset=utf-8'
        @$cookies = []
        @$startTime = Date.now()
        @$stream = null
        @$content = null

        @responded = no

        if @options.compression
            acceptEncoding = req.headers['accept-encoding']

            if acceptEncoding?
                if acceptEncoding.match /\bdeflate\b/
                    @$stream = Zlib.createDeflate()
                    @$headers['content-encoding'] = 'deflate'
                else if acceptEncoding.match /\bgzip\b/
                    @$stream = Zlib.createGzip()
                    @$headers['content-encoding'] = 'gzip'

        @$stream = new Stream.PassThrough if not @$stream?
        patchOriginalResponse @res


    # set content
    content: (val) ->
        @$content = val
        @


    # set status code
    status: (code) ->
        @$statusCode = Status code
        @


    # set cookie
    cookie: (key, val, options) ->
        @$cookies.push Cookie.serialize key, val, options
        @


    # set header
    header: (key, val) ->
        key = key.toLowerCase()
        @$headers[key] = val
        @


    # set finish
    finish: (@finish) ->
        @res.on 'finish', =>
            @finish.call @, @res.statusCode, @res.bytes, Date.now() - @$startTime

    
    # respond
    respond: ->
        @res.statusCode = @$statusCode
        @res.statusMessage = Status[@$statusCode]

        
        for key, val of @$headers
            key = key.replace /(^|-)([a-z])/g, (m, a, b) ->
                a + b.toUpperCase()

            @res.setHeader key, val

        @res.setHeader 'Set-Cookie', @$cookies if @$cookies.length > 0
        @$stream.pipe @res

        if @$content instanceof Stream.Readable
            @$content.pipe @$stream
        else
            @$stream.end @$content


module.exports = Response


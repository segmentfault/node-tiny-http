Request = require './request'
Response = require './response'
Result = require './result'

# routes map
routes = []

# default functions
defaults = []


# create match uri pattern
match = (method, pattern) ->
    keys = []

    # replace as regex
    pattern = pattern.replace /(:|%)([_a-z0-9-]+)/i, (m, prefix, name) ->
        keys.push name
        if prefix == ':' then '([^\\/]+)' else '(.+)'

    r = new RegExp "^#{pattern}$", 'g'

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


# register routes
register = (method, pattern, fn) ->
    tester = match method, pattern
    functions = []
    pushed = no
    raw = no

    routes.push
        get: ->
            if not pushed
                functions.push fn
                pushed = yes

            [tester, functions, raw]
        raw: ->
            raw = yes
            @
        use: (actions...) ->
            for action in actions
                if action instanceof Array
                    for item in action
                        functions.push item
                else
                    functions.push action
            @


# register default functions
use = (actions...) ->
    for action in actions
        if action instanceof Array
            for item in action
                defaults.push item
        else
            defaults.push action


# handler for http
handler = (result, options) ->

    (req, res) ->
        
        response = new Response res, options

        new Request req, options, (request) ->
            context = { request, response }
            callbacks = []
            returned = no
            index = -1
            resultArgs = null
            next = null

            respond = ->
                [name, args] = resultArgs
                result[name].apply null, args
                    .call null, request, response
                response.respond() if not response.responded

            done = (name, args...) ->
                return if returned
                returned = yes
                index = callbacks.length
                name = 'blank' if not result[name]?
                resultArgs = [name, args]
                
                if next then next() else respond()

            for def in routes
                [tester, functions, raw] = def.get()
                params = {}

                # deny not matched
                continue if not tester request.method, request.path, params
                request.set params

                do next = (callback = null) ->
                    if returned
                        index -= 1

                        if index >= 0
                            callbacks[index].apply context, resultArgs
                        else
                            respond()
                    else
                        callbacks.push callback if callback?
                        index += 1

                        if raw
                            fn = functions[index]
                        else
                            fn = if index >= defaults.length then functions[index - defaults.length] else defaults[index]

                        fn.call context, done, next if fn?

                return

            done 'notFound'


module.exports = { register, handler, use }


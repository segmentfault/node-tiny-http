Request = require './request'
Response = require './response'
Result = require './result'

# routes map
routes = {}


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
register = (method, pattern, actions) ->
    tester = match method, pattern
    functions = []

    for action in actions
        functions.push action if action not in functions

    routes[pattern] = [tester, functions]


# handler for http
handler = (result, options) ->

    (req, res) ->
        
        response = new Response res, options

        new Request req, options, (request) ->
            _result = null
            context = { request, response }
            
            done = (name, args...) ->
                name = 'blank' if not result[name]?
                result[name].apply null, args
                    .call null, request, response
                response.respond() if not response.responded

            for pattern, def of routes
                [tester, functions] = def
                params = {}
                index = -1

                # deny not matched
                continue if not tester request.method, request.path, params
                request.set params

                do next = ->
                    index += 1
                    fn = functions[index]
                    fn.call context, done, next if fn?

                break


module.exports = { register, handler }


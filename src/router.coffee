Url = require 'url'

# routes map
routes = {}

# rules map
rules = {}


# find rule by name
findRule = (name) ->
    currentRules = []

    if rules[name]?
        [fn, depends] = rules[name]
        
        if depends?
            for n in depends
                found = ruleFind n

                for item in found
                    currentRules.push item if item not in currentRules
        
        currentRules.push rules[name]
    
    currentRules


# create match uri pattern
match = (method, pattern) ->
    keys = []
    currentRules = []
    currentRuleFunctions = []

    # split rules
    parts = pattern.split ' '

    if parts.length > 1
        currentRules = parts[0].split ';'
        pattern = parts[1]

    for name in currentRules
        found = findRule name

        for item in found
            currentRuleFunctions.push item if item not in currentRuleFunctions

    # replace as regex
    pattern = pattern.replace /(:|%)([_a-z0-9-]+)/i, (m, prefix, name) ->
        keys.push name
        if prefix == ':' then '([^\\/]+)' else '(.+)'

    r = new RegExp "^#{pattern}$", 'g'

    [currentRuleFunctions, \
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
    ]


# register rule
registerRule = (name, fn, depends = null) ->
    if depends? and depends not instanceof Array
        depends = depends.split ';'
    rules[name] = [fn, depends]


# register routes
register = (method, pattern, fn) ->
    [currentRules, tester] = match method, pattern
    routes[pattern] = [tester, currentRules, fn]


# handler for http
handler = (req, res) ->
    parts = Url.parse req.url, yes
    uri = if parts.pathname? then parts.pathname else '/'
    params = parts.query
    result = null

    for pattern, def of routes
        [tester, currentRules, fn] = def

        # deny not matched
        continue if not tester req.method, uri, params

        for rule in currentRuleFunctions
            result = rule.call results, params, req if rules[rule]?
            break if result instanceof Function

        result = fn.call results, params, req if result not instanceof Function
        break

    result = results.notFound() if not result?
    result.call null, req, res, params

module.exports = { register, registerRule, handler }


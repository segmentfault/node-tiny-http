// Generated by CoffeeScript 1.10.0
(function() {
  var Request, Response, Router, match,
    slice = [].slice;

  Request = require('./request');

  Response = require('./response');

  match = function(method, pattern) {
    var keys, r;
    keys = [];
    pattern = pattern.replace(/(:|%)([_a-z0-9-]+)/ig, function(m, prefix, name) {
      keys.push(name);
      if (prefix === ':') {
        return '([^\\/]+)';
      } else {
        return '(.+)';
      }
    });
    r = new RegExp("^" + pattern + "$", 'g');
    return function(requestMethod, uri, params) {
      var i, j, len, result, val;
      if ((method != null) && requestMethod !== method) {
        return false;
      }
      result = r.exec(uri);
      r.lastIndex = 0;
      if (result != null) {
        for (i = j = 0, len = result.length; j < len; i = ++j) {
          val = result[i];
          if (i === 0) {
            continue;
          }
          params[keys[i - 1]] = val;
        }
        return true;
      }
      return false;
    };
  };

  Router = (function() {
    function Router() {
      this.routes = [];
      this.defaults = [];
    }

    Router.prototype.register = function(method, pattern, fn) {
      var def, functions, pushed, raw, tester;
      tester = match(method, pattern);
      functions = [];
      pushed = false;
      raw = false;
      def = {
        get: function() {
          if (!pushed) {
            functions.push(fn);
            pushed = true;
          }
          return [tester, functions, raw];
        },
        raw: function() {
          raw = true;
          return this;
        },
        use: function() {
          var action, actions, item, j, k, len, len1;
          actions = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          for (j = 0, len = actions.length; j < len; j++) {
            action = actions[j];
            if (action instanceof Array) {
              for (k = 0, len1 = action.length; k < len1; k++) {
                item = action[k];
                functions.push(item);
              }
            } else {
              functions.push(action);
            }
          }
          return this;
        }
      };
      this.routes.push(def);
      return def;
    };

    Router.prototype.use = function() {
      var action, actions, item, j, len, results;
      actions = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      results = [];
      for (j = 0, len = actions.length; j < len; j++) {
        action = actions[j];
        if (action instanceof Array) {
          results.push((function() {
            var k, len1, results1;
            results1 = [];
            for (k = 0, len1 = action.length; k < len1; k++) {
              item = action[k];
              results1.push(this.defaults.push(item));
            }
            return results1;
          }).call(this));
        } else {
          results.push(this.defaults.push(action));
        }
      }
      return results;
    };

    Router.prototype.handler = function(result, options) {
      return (function(_this) {
        return function(req, res) {
          var response;
          response = new Response(res, options);
          return new Request(req, options, function(request) {
            var callbacks, context, def, done, functions, index, j, len, next, params, raw, ref, ref1, respond, resultArgs, returned, tester;
            context = {
              request: request,
              response: response
            };
            callbacks = [];
            returned = false;
            index = -1;
            resultArgs = null;
            next = null;
            respond = function() {
              var args, name;
              name = resultArgs[0], args = resultArgs[1];
              result[name].apply(null, args).call(null, request, response);
              if (!response.responded) {
                return response.respond();
              }
            };
            done = function() {
              var args, name;
              name = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
              if (returned) {
                return;
              }
              returned = true;
              index = callbacks.length;
              if (result[name] == null) {
                name = 'blank';
              }
              resultArgs = [name, args];
              if (next) {
                return next();
              } else {
                return respond();
              }
            };
            ref = _this.routes;
            for (j = 0, len = ref.length; j < len; j++) {
              def = ref[j];
              ref1 = def.get(), tester = ref1[0], functions = ref1[1], raw = ref1[2];
              params = {};
              if (!tester(request.method, request.path, params)) {
                continue;
              }
              request.set(params);
              (next = function(callback) {
                var fn;
                if (returned) {
                  index -= 1;
                  if (index >= 0) {
                    return callbacks[index].apply(context, resultArgs);
                  } else {
                    return respond();
                  }
                } else {
                  if (callback != null) {
                    callbacks.push(callback);
                  }
                  index += 1;
                  if (raw) {
                    fn = functions[index];
                  } else {
                    fn = index >= _this.defaults.length ? functions[index - _this.defaults.length] : _this.defaults[index];
                  }
                  if (fn != null) {
                    return fn.call(context, done, next);
                  }
                }
              })(null);
              return;
            }
            return done('notFound');
          });
        };
      })(this);
    };

    return Router;

  })();

  module.exports = Router;

}).call(this);

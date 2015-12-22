var http = require('../build/http');

var interceptorOne = function (request, response, next) {
    response.header('ip', request.ip());

    next();

    response.header('agent', request.agent);
};

http.on('/', interceptorOne, function (req) {
    return this.json(req.method);
});

http.start({ host : 'localhost', port : 9999 });


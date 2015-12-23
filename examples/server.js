var http = require('../build/http');

var interceptorOne = function (next) {
    this.response.header('ip', this.request.ip());
    this.text = '123';

    next();

    this.response.header('agent', this.request.agent);
};

http.on('/', interceptorOne, function () {
    return this.result.json(this.text + this.request.method);
});

http.start({ host : 'localhost', port : 9999 });


var Http = require('../build/http');

http = new Http;

var interceptorOne = function (done, next) {
    this.response.header('ip', this.request.ip());
    this.text = '123';

    this.response.finish(function (code, length, time) {
        console.log(code, length, time);
    });

    next(function (name, args) {
        console.log(2, name, args);

        next();
    });

    console.log(this.request.agent);
};

http.on('/', function (done) {
    return done('json', this.text + this.request.method);
}).use(function (done, next) {
    this.response.header('agent', this.request.agent);

    next(function (name, args) {
        console.log(1, name, args);
        args[0] = 'changed ' + args[0];

        next();
    });
});

http.use(interceptorOne);

http.assets('/src', __dirname + '/../src');

http.listen({ host : 'localhost', port : 9999 });


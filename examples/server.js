var http = require('../build/http');

var interceptorOne = function (done, next) {
    this.response.header('ip', this.request.ip());
    this.text = '123';

    next(function (name, args) {
        console.log(2, name, args);
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
    });
});

http.use(interceptorOne);

http.assets('/src', __dirname + '/../src');

http.start({ host : 'localhost', port : 9999 });


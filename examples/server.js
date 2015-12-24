var http = require('../build/http');

var interceptorOne = function (done, next) {
    this.response.header('ip', this.request.ip());
    this.text = '123';

    next();

    console.log(this.request.agent);
};

http.on('/', function (done) {
    return done('json', this.text + this.request.method);
});

http.use(interceptorOne);

http.assets('/src', __dirname + '/../src');

http.start({ host : 'localhost', port : 9999 });


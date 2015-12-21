var http = require('../build/http');

http.on('/', function (req) {
    return this.json(req.method);
});

http.start(8888, 'localhost');


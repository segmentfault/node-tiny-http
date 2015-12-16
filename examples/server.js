var http = require('../build/http');

http.on('/', function (params) {
    return this.json(params);
});

http.start(8888, 'localhost');


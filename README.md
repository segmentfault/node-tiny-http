# 一个简单的可扩展的node.js web框架

## 为什么要开发这个框架?

目前node.js上的http框架已经很多，大名鼎鼎的`express`和`koa`都有大量的用户。但是我在使用后发现在很多项目中，它们在某些方面显得过于繁琐，而有些需要重度使用的地方又处理得太过简陋。因此我们结合自己的项目经验开发了这款web框架。目的是打造一款便于使用的，API友好的，可以高度自定义的框架。

## 安装

我们会及时发布到npm上，你只需要在项目中

```
npm install node-tiny-http
```

## 使用

### Hello World

通常我们用一个最简单的例子来展示框架的基本运行情况

```javascript
var http = require('node-tiny-http');

http.get('/', function (done) {
    return done('content', 'Hello World!');
});

http.start({ host : 'localhost', port : 9999 });
```

打开浏览器并访问<http://localhost:9999/>即可看到效果。


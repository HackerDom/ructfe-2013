#!/usr/bin/node

var express = require('express');
var routes = require('./routes');

var app = express();

app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

app.use(express.bodyParser());
app.use(express.cookieParser());

app.get('/registration', routes.registration);
app.post('/tweet', routes.tweet);
app.get('/', routes.index);
app.get('/:id', routes.home)

app.listen(3000, function(){
  console.log('listening');
});

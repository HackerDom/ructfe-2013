#!/usr/bin/node

var express = require('express');
var routes = require('./routes');

var app = express();

app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

app.use(express.logger('dev'));
app.use(express.bodyParser());

app.post('/create', routes.create);
app.get('/get/:id', routes.get);

app.listen(3000, function(){
  console.log('listening');
})

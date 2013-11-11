#!/usr/bin/node

var express = require('express');
var routes = require('./routes');

var app = express();

app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

app.use(express.logger('dev'));
app.use(express.bodyParser());

app.get('/', routes.index);
app.get('/delete/:id', routes.destroy);
app.post('/create', routes.create);

app.listen(3000, function(){
  console.log('listening');
})

#!/usr/bin/node

var express = require('express');
var routes = require('./routes');

var app = express();

app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

app.use(express.bodyParser());
app.use(express.cookieParser());
app.use(express.logger('dev'));
app.use(routes.getUser);

app.get('/', routes.index);
app.get('/signin', routes.signin);
app.get('/signup', routes.signup);
app.post('/tweet', routes.tweet);
app.post('/checkpub', routes.checkpub);

app.get('/retweet/:id', routes.retweet);
app.get('/:id', routes.home)
app.post('/checkrandom/:id', routes.checkrandom)
app.get('/tryfollow/:id', routes.tryfollow);
app.get('/follow/:id', routes.follow);

app.listen(0xbeef, function(){
  console.log('listening now');
});

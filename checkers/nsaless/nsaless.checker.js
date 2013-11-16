#!/usr/bin/node

var http = require('http');
var querystring = require('querystring');
var EventEmitter = new require('events').EventEmitter
var exit_event = new EventEmitter()

exit_event.on('exit', function(code) {
  process.exit(code);
});

codes = {
  'SERVICE_OK' : 101,
  'FLAG_GET_ERROR' : 102,
  'SERVICE_CORRUPT' : 103,
  'SERVICE_FAIL' : 104,
  'INTERNAL_ERROR' : 110
};

var done = function(code) {
  console.log('status: ' + code);
  exit_event.emit('exit', code);
};


var put = function(ip, id, flag) {
  console.log('put');

  console.log('ip: ' + ip);
  console.log('id: ' + id);
  console.log('flag: ' + flag);

  var post_data = querystring.stringify({
    'id' : id,
    'message' : flag
  });

  var options = {
    host: ip,
    port: 3000,
    path: '/create',
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': post_data.length
    }
  };
  
  var post_req = http.request(options, function(res) {
      res.setEncoding('utf8');

      var data = "";
      res.on('data', function (chunk) {
        data += chunk;
      });

      res.on('end', function() {
        console.log('response: ' + data);
        var return_value;
        if (data === id) {
          return_value = codes['SERVICE_OK'];
        } else {
          return_value = codes['SERVICE_CORRUPT'];
        }
        done(return_value);
      });

  });

  post_req.on('error', function(err) {
    console.log(err);
    done(codes['SERVICE_FAIL']);
  });

  post_req.write(post_data);
  post_req.end();
};

var get = function(ip, id, flag) {
  console.log('get');

  console.log('ip: ' + ip);
  console.log('id: ' + id);
  console.log('flag: ' + flag);

  var options = {
    host: ip,
    port: 3000,
    path: '/get/' + id
  };

  var req = http.request(options, function(res) {
      res.setEncoding('utf8');
      
      var data = "";
      res.on('data', function (chunk) {
        data += chunk;
      });

      res.on('end', function() {
        console.log('response: ' + data);
        var return_value;
        if (data === flag) {
          return_value = codes['SERVICE_OK'];
        } else {
          return_value = codes['FLAG_GET_ERROR'];
        }
        done(return_value);
      });
      
      res.on('error', function() {
        console.log("qwer");
      });
  }).on('error', function(err) {
    console.log(err);
    done(codes['SERVICE_FAIL']);
  });

  req.end();
};

var check = function(ip, id, flag) {
  console.log('check');
  done(codes['SERVICE_OK']);
};

var handlers = {
  'put' : put,
  'get' : get,
  'check' : check
}

process.argv.splice(0, 2);
var argv = process.argv;

if (argv.length < 2) {
  console.log('argv length missmatch');
  process.exit(codes['INTERNAL_ERROR']);
}

handlers[argv[0]](argv[1], argv[2], argv[3]);

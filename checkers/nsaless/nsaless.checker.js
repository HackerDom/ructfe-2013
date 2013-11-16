#!/usr/bin/node

http = require('http');
codes = {
  'SERVICE_OK' : 101,
  'FLAG_GET_ERROR' : 102,
  'SERVICE_CORRUPT' : 103,
  'SERVICE_FAIL' : 104,
  'INTERNAL_ERROR' : 110
};

put = function(ip, id, flag) {
  console.log('put');
};

get = function(ip, id, flag) {
  console.log('get');
};

check = function(ip, id, flag) {
  console.log('check');
  var return_value = codes['SERVICE_OK'];
  console.log('status: ' + return_value);
  return return_value;
};

handlers = {
  'put' : put,
  'get' : get,
  'check' : check
}

process.argv.splice(0, 2);
var argv = process.argv;
process.exit(handlers[argv[0]](argv[1], argv[2], argv[3]));

#!/usr/bin/node

var http = require('http');
var EventEmitter = new require('events').EventEmitter;
var exit_event = new EventEmitter();
var jsdom = require('jsdom');
var async = require('async');
var utils = require('./utils');

exit_event.on('exit', function(code) {
    process.exit(code);
});


var done = function(code) {
    console.log('status: ' + code);
    exit_event.emit('exit', code);
};

var put = function(ip, id, flag) {
    console.error('put');

    console.error('ip: ' + ip);
    console.error('id: ' + id);
    console.error('flag: ' + flag);

    var userId = null;
    var userCookie = null;

    async.waterfall([
        function(next) {
            utils.createUser(ip, next);
        },

        function(id, cookie, next) {
            userId = id;
            userCookie = cookie;
            utils.tweetMessage(ip, cookie, flag, next);
        },

        function(next) {
            async.map([0, 1, 2, 3, 4, 5, 6, 7],
            function(number, callback) {
                    utils.createUser(ip, function(err, id, cookie) {
                        callback(err, {'id': id, 'cookie': cookie});
                    });
            },
            function(err, results) {
                next(err, results);
            });
        },

        function(users, next) {
            async.map(users,
            function(user, callback) {
                utils.tryFollow(ip, user.cookie, userId, function(data) {
                    callback(null, user);
                });
            },
            function(err, results) {
                setInterval(function(){ next(err, results); }, 3000);
            });
        },

        function(users, next) {
            async.map(users,
            function(user, callback) {
                utils.acceptFollow(ip, userCookie, user.id, function(data) {
                    callback(null, user);
                });
            },
            function(err, results) {
                next(err, utils.codes['SERVICE_OK']);
            });
        }

        ], function(err, code) {
            done(code);
        });
};

var get = function(ip, id, flag) {
    console.log('get');

    console.log('ip: ' + ip);
    console.log('id: ' + id);
    console.log('flag: ' + flag);

    var options = {
        host: ip,
        port: 48879,
        path: '/get/' + id
    };

    httpClient.get(ip, '/signup', {}, function(data) {

    }).end();
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

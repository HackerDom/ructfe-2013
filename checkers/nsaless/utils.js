var jsdom = require('jsdom');
var querystring = require('querystring');
var http = require('http');

exports.codes = {
    'SERVICE_OK' : 101,
    'FLAG_GET_ERROR' : 102,
    'SERVICE_CORRUPT' : 103,
    'SERVICE_FAIL' : 104,
    'INTERNAL_ERROR' : 110
};

var httpClient = {
    'put': function(host, url, cookie, post_data, callback) {
        var options = {
            'host': host,
            'port': 48879,
            'path': url,
            'method': 'POST',
            'headers': {
                'Cookie': cookie,
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        };

        var post_req = http.request(options, function(res) {
            res.setEncoding('utf8');

            var data = "";
            res.on('data', function (chunk) {
                data += chunk;
            });

            res.on('end', function() {
                callback(data)
            });

        });


        post_req.on('error', function(err) {
            console.log(err);
            done(codes['SERVICE_FAIL']);
        });

        post_req.write(querystring.stringify(post_data));
        post_req.end();
    },

    'get': function(host, url, cookie, callback) {

        var options = {
            'host': host,
            'port': 48879,
            'path': url,
            'headers' : {
                'Cookie': cookie,
            }
        }

        http.request(options, function(res) {
            res.setEncoding('utf8');

            var data = "";
            res.on('data', function (chunk) {
                data += chunk;
            });

            res.on('end', function() {
                var responseCookies = "";
                if (res.headers && res.headers['set-cookie'] && res.headers['set-cookie'].length != 0) {
                    responseCookies = res.headers['set-cookie'][0];
                }
                callback(data, responseCookies);
            });
        }).on('error', function(err) {
            console.log(err);
            done(codes['SERVICE_FAIL']);
        }).end();
    }
}

exports.checkTweet = function(ip, cookie, id, flag, callback) {
    httpClient.get(ip, '/' + id, cookie, function(data, cookie) {
        jsdom.env(data,  ["http://code.jquery.com/jquery.js"], function(err, window) {
            callback(window.$("#last_tweet").text() == flag);
        });
    });
}

exports.tweetMessage = function(ip, cookie, message, callback) {
    httpClient.put(ip, '/tweet', cookie, { 'message': message }, function(data) {
        callback(null);
    });
}

exports.acceptFollow = function(ip, cookie, id, callback) {
    httpClient.get(ip, '/follow/' + id, cookie, function(data, cookie) {
        callback(data);
    });
}

exports.tryFollow = function(ip, cookie, id, callback) {
    httpClient.get(ip, '/tryfollow/' + id, cookie, function(data, cookie) {
        callback(data);
    });
}

exports.createUser = function(ip, callback) {
    httpClient.get(ip, '/signup', '', function(data, cookie) {
        jsdom.env(data,  ["http://code.jquery.com/jquery.js"], function(err, window) {
            var userId = window.$("#user_id").text();
            if (userId) {
                callback(null, userId, cookie);
            } else {
                callback('Service corrupt', codes['SERVICE_CORRUPT']);
            }
        });
    });
}

var jsdom = require('jsdom');
var querystring = require('querystring');
var http = require('http');
var EventEmitter = new require('events').EventEmitter;
var exit_event = new EventEmitter();
var bignum = require('bignum');

exit_event.on('exit', function(code) {
    process.exit(code);
});
var done = function(code) {
    console.error('status: ' + code);
    exit_event.emit('exit', code);
};


exports.codes = {
    'SERVICE_OK' : 101,
    'FLAG_GET_ERROR' : 102,
    'SERVICE_CORRUPT' : 103,
    'SERVICE_FAIL' : 104,
    'INTERNAL_ERROR' : 110
};

var httpClient = {
    'post': function(host, url, cookie, post_data, callback) {
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
                var responseCookies = "";
                if (res.headers && res.headers['set-cookie'] && res.headers['set-cookie'].length != 0) {
                    responseCookies = res.headers['set-cookie'][0];
                }
                callback(data, responseCookies);
            });

        });


        post_req.on('error', function(err) {
            console.error(err);
            done(exports.codes['SERVICE_FAIL']);
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
            console.error(err);
            done(exports.codes['SERVICE_FAIL']);
        }).end();
    }
}

exports.decrypt = function(key, message) {
    var priv = JSON.parse(new Buffer(key, 'base64').toString('utf-8'));
    var p = bignum(priv.p);
    var q = bignum(priv.q);
    var e = bignum(priv.e);
    var n = p.mul(q);
    var phi = p.sub(1).mul(q.sub(1));
    var d = e.invertm(phi);
    return bignum(bignum(message)).powm(d, n).toString();
}

exports.signin = function(ip, id, key, callback) {
    httpClient.post(ip, '/checkpub', "", { 'id': id }, function(data) {
        jsdom.env(data,  ["http://code.jquery.com/jquery.js"], function(err, window) {
            var randomId = window.$("#randomid").text();
            var cryptedRandom = window.$("#cryptedrandom").text();
            var random = exports.decrypt(key, cryptedRandom);
            httpClient.post(ip, '/checkrandom/' + randomId, "", { 'id': random }, function(_, cookies) {
                callback(null, cookies);
            });
        });
    });
}

exports.checkTweet = function(ip, cookie, id, flag, key, callback) {
    httpClient.get(ip, '/' + id, cookie, function(data, cookie) {
        jsdom.env(data,  ["http://code.jquery.com/jquery.js"], function(err, window) {
            var decryptedNumber = exports.decrypt(key, window.$("#last_tweet").text());
            var oldFlag = bignum(decryptedNumber).toBuffer().toString('utf-8');
            callback(oldFlag == flag);
        });
    });
}

exports.tweetMessage = function(ip, cookie, message, callback) {
    httpClient.post(ip, '/tweet', cookie, { 'message': message }, function(data) {
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
            var userKey = window.$("#priv").text();
            if (userId) {
                callback(null, userId, cookie, userKey);
            } else {
                callback('Service corrupt', codes['SERVICE_CORRUPT']);
            }
        });
    });
}

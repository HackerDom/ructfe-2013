var redis = require("redis"),
    client = redis.createClient();
var bignum = require("bignum");
var crypto =  require('./crypto')
var users = require('./users')

exports.saveTweet = function(user, message) {
    if (user) {
        client.hkeys(user.id + '_followers', function(err, reply) {
            var tweetId = crypto.random(64);
            var tweet = {'id': tweetId, 'tweet': message};
            client.lpush(user.id + '_tweets', JSON.stringify(tweet));

            if (reply) {
                for (var i = 0; i < reply.length; ++i) {
                    client.lpush(reply[i] + '_tweets', JSON.stringify(tweet));
                }
            }
        });
    }
}

exports.getTweets = function(user, callback) {
    if (user) {
        client.lrange(user.id + '_tweets', 0, -1, function(err, reply) {
            if (reply) {
                callback(reply.map(function(tweet) {
                    return crypto.encryptTweet(user, JSON.parse(tweet));
                }));
            } else {
                callback(undefined);
            }
        });
    } else {
        callback(undefined);
    }
}

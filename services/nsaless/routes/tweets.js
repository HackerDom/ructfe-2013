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
            client.rpush(user.id + '_tweets', JSON.stringify(tweet));

            if (reply) {
                for (var i = 0; i < reply.length; ++i) {
                    client.rpush(reply[i] + '_tweets', JSON.stringify(tweet));
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

exports.store_tweet = function (id, message) {
    var tweet_id = bignum.rand(bignum(2).pow(64)).toString();
    client.hget('tweets', id, function(err, reply) {
        var tweets = null;
        var tweet = {'id': tweet_id, 'message': message};
        client.set(tweet_id, JSON.stringify(tweet));
        if (reply == null) {
            tweets = {
                'tweets': [tweet]
            }
        } else {
            tweets = JSON.parse(reply);
            tweets.tweets.unshift(tweet);
        } 
        client.hset('tweets', id, JSON.stringify(tweets));
    });
}

exports.retweet = function(id, tweet_id) {
    client.get(tweet_id, function(err, reply) {
        if (reply) {
            exports.store_tweet(id, JSON.parse(reply).message);
        }
    });
}

exports.get_tweets = function(id, callback) {
    client.hget('tweets', id, function(err, reply) {
        if (reply == null) {
            callback([]);
        } else {
            callback(JSON.parse(reply).tweets);
        }
    });
}


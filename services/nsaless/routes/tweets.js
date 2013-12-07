var redis = require("redis"),
    client = redis.createClient();
var bignum = require("bignum");
var crypto =  require('./crypto')
var users = require('./users')

exports.saveTweet = function(user, message) {
    if (user) {
        var tweetId = crypto.random(64);
        var tweet = {'id': tweetId, 'tweet': message};
        client.hset('tweets', tweetId, JSON.stringify(tweet));
        client.set(tweetId, JSON.stringify(tweet));
        user.tweets.unshift(tweetId);
        users.saveUser(user);
    }
}

exports.getTweets = function(user, callback) {
    if (user) {
        client.hmget('tweets', user.tweets, function(err, reply) {
            if (reply) {
                callback(reply.map(function(tweet) {
                    return JSON.parse(tweet); 
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


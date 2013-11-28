var redis = require("redis"),
    client = redis.createClient();

exports.store_tweet = function (id, tweet) {
    client.hget('tweets', id, function(err, reply) {
        var tweets = null;
        if (reply == null) {
            tweets = {
                'tweets': [tweet]
            }
        } else {
            tweets = JSON.parse(reply);
            tweets.tweets.push(tweet);
        } 
        client.hset('tweets', id, JSON.stringify(tweets));
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


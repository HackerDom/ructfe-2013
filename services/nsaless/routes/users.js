var redis = require("redis"),
    client = redis.createClient();
var bignum = require("bignum");

exports.addPending = function(user_id, follower_id) {
    client.hset('pending', follower_id, user_id);
}

exports.addFollower = function(user_id, follower_id) {
    client.hget('pending', follower_id, function(err, reply) {
        if (reply != null && user_id == reply) {
            client.hset(user_id + '_followers', follower_id, follower_id);
            client.hdel('pending', follower_id);
            client.lrange(user_id + '_tweets', 0, -1, function(err, reply) {
                if (reply) {
                    for (var i = 0; i < reply.length; ++i) {
                        client.lpush(follower_id + '_tweets', reply[i]);
                    }
                }
            });
        }
    });
}

exports.getFollowers = function(user_id, callback) {
    client.hkeys(user_id + '_followers', function(err, reply) {
        if (reply) {
            callback(reply);
        } else {
            callback([]);
        }
    });
}

exports.getPendings = function(user_id, callback) {
    client.hgetall('pending', function(err, reply) {
        if (reply) {
            callback(reply);
        } else {
            callback({});
        }
    });
}

exports.getUserFromId = function(id, callback) {
    var user = null
    client.hget('users', id, function(err, reply) {
        if (reply != null) {
            user = JSON.parse(reply);
        }
        callback(user);
    });
}

exports.getUserFromCookie = function(session_id, callback) {
    var user = null
    if (session_id) {
        client.get(session_id, function(err, reply) {
            if (reply) {
                exports.getUserFromId(reply, callback);
            } else {
                callback(user);
            }
        });
    } else {
        callback(user);
    }
}

exports.createUser = function(req, res) {
    return {
        'id': bignum.rand(bignum(2).pow(64)).toString(),
        'followers': [],
        'tweets': [],
        'pending_followers': {}
    };
}

exports.saveUser = function(user) {
    client.hset('users', user.id ,JSON.stringify(user));
}

exports.getUsers = function(callback) {
    client.hvals('users', function(err, reply) {
        if (reply) {
            callback(reply.map(function(user) {
                return JSON.parse(user);
            }));
        } else {
            callback([]);
        }
    });
}

exports.createSession = function(req, res, user) {
    var session_id = bignum.rand(bignum(2).pow(64)).toString();
    client.set(session_id, user.id);
    client.expire(session_id, 5 * 60);
    res.cookie('id', session_id);
}

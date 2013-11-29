var redis = require("redis"),
    client = redis.createClient();
var bignum = require("bignum");

exports.getUserFromId = function(req, res, id, callback) {
    var user = null
    client.hget('users', id, function(err, reply) {
        if (reply != null) {
            user = JSON.parse(reply);
        }
        callback(user);
    });
}

exports.getUserFromCookie = function(req, res, callback) {
    var user = null
    var session_id = req.cookies.id;
    if (session_id) {
        client.get(session_id, function(err, reply) {
            if (reply) {
                exports.getUserFromId(req, res, reply, callback);
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
        'tweets': []
    };
}

exports.saveUser = function(user) {
    client.hset('users', user.id ,JSON.stringify(user));
}

exports.createSession = function(req, res, user) {
    var session_id = bignum.rand(bignum(2).pow(64)).toString();
    client.set(session_id, user.id);
    client.expire(session_id, 5 * 60);
    res.cookie('id', session_id);
}

/*
exports.get_id = function(req, res) {
    if (req.cookies.id) {
        return req.cookies.id;
    } else {
        return null;
    }
}

exports.get_id_or_signup = function(req, res, callback) {
    var id = req.cookies.id;
    if (id) {
        client.get(id, function(err, reply) {
            if (reply == null) {
                res.redirect('/registration');
            } else {
                callback(id);
            }
        });
    } else {
        res.redirect('/registration');
    }
}

exports.register_user = function(req, res) {
    var id = bignum.rand(bignum(2).pow(64)).toString();
    client.set(id, id);
    client.expire(id, 5*60);
    res.cookie('id', id);
    return id;
}

*/

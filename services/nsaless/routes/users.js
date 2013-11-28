var redis = require("redis"),
    client = redis.createClient();
var bignum = require("bignum");

exports.getUserFromId = function(req, res, id, callback) {
    var user = {}
    client.get(id, function(err, reply) {
        if (reply != null) {
            user = JSON.parse(reply);
        }
        callback(user);
    });
}

exports.getUserFromCookie = function(req, res, callback) {
    var user = {}
    var id = req.cookies.id;
    if (id) {
        exports.getUserFromId(req, res, id, callback);
    } else {
        callback(user);
    }
}

exports.createUser = function(req, res) {
    return {
        'id': bignum.rand(bignum(2).pow(64)),
        'tweets': []
    };
}

exports.saveUser = function(req, res, user) {
    client.set(user.id, JSON.stringify(user));
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

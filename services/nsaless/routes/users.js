var redis = require("redis"),
    client = redis.createClient();
var bignum = require("bignum");

exports.get_id_or_redirect = function(req, res, callback) {
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

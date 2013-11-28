var bignum = require("bignum");
var crypto = require("./crypto");
var storage = require("./storage")
var users = require("./users")


exports.index = function(req, res) {
    users.get_id_or_redirect(req, res, function(id) {
        storage.get_tweets(id, function(tweets) {
            res.render('index', { 'id': id, 'tweets': tweets });
        });
    });
}

exports.registration = function(req, res) {
    var id = users.register_user(req, res);
    res.render('registration', {'id': id});
}

exports.tweet = function(req, res) {
    users.get_id_or_redirect(req, res, function(id) {
        var message = req.body.message;
        storage.store_tweet(id, message);
        res.redirect('/');
    });
}

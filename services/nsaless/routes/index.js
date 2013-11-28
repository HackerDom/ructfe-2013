var bignum = require("bignum");
var crypto = require("./crypto");
var storage = require("./storage")
var users = require("./users")


exports.index = function(req, res) {
    users.get_id_or_signup(req, res, function(id) {
        res.redirect('/' + id);
    });
}

exports.home = function(req, res) {
    var url_id = req.params.id;
    var cookie_id = users.get_id(req, res);
    storage.get_tweets(url_id, function(tweets) {
        res.render('home', { 'id': url_id, 'tweets': tweets, 'is_home': url_id == cookie_id });
    });
}

exports.registration = function(req, res) {
    var id = users.register_user(req, res);
    res.render('registration', {'id': id});
}

exports.tweet = function(req, res) {
    users.get_id_or_signup(req, res, function(id) {
        var message = req.body.message;
        storage.store_tweet(id, message);
        res.redirect('/');
    });
}

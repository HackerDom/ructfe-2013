var crypto = require("./crypto");

var tweets = require("./tweets")
var users = require("./users")

exports.getUser = function(req, res, next) {
    users.getUserFromCookie(req, res, function(user) {
        res.user = user;
        next();
    });
}

exports.index = function(req, res) {
    if (res.user.authorized) {
        res.redirect('/' + res.user.id);
    } else {
        res.redirect('/signin');
    }
}

exports.home = function(req, res) {
    var id = req.params.id;
    users.getUserFromId(req, res, id, function(user) {
        res.render('home', {
            'cookie_user': res.user,
            'url_user': user
        });
    });
}

exports.signin = function(req, res) {
    res.render('signin');
}

exports.signup = function(req, res) {
    var user = users.createUser();
    var keys = crypto.buildKeys();
    user.pub = keys.pub;
    res.render('signup', {
        'user': user,
        'keys': keys
    });
}

exports.checkpub = function(req, res) {
    res.end()
}

exports.tweet = function(req, res) {
    res.end()
}

exports.retweet = function(req, res) {
    res.end()
}


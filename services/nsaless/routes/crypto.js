var bignum = require('bignum')
var redis = require("redis"),
    client = redis.createClient();

var getPrime = function(bits) {
    return bignum.prime(bits);
}

var pubKey = function(e, n) {
    return JSON.stringify({
        'e': e.toString(),
        'n': n.toString()
    })
}

var privKey = function(e, p, q) {
    return JSON.stringify({
        'e': e.toString(),
        'p': p.toString(),
        'q': q.toString()
    })
}

exports.buildKeys = function() {
    var p = getPrime(256);
    var q = getPrime(256);

    var e = bignum(7);
    var n = p.mul(q);
    var phi = p.sub(1).mul(q.sub(1));
    var d = e.invertm(phi);

    return {
        'pub': pubKey(e, n),
        'priv': privKey(e, p, q)
    }
}

exports.random = function(bits) {
    return bignum.rand(bignum(2).pow(bits)).toString();
}

exports.encryptWithUser = function(user, num) {
    var pub = JSON.parse(user.pub);
    return bignum(num).powm(pub.e, pub.n).toString();
}

exports.toBase64 = function(string) {
    return new Buffer(string).toString('base64')
}

exports.fromBase64 = function(string) {
    return new Buffer(string, 'base64').toString('utf-8')
}

exports.saveRandom = function(user, random) {
    var id = exports.random(64);
    var userRandom = { 'random': random, 'id': user.id };
    client.hset('randoms', id, JSON.stringify(userRandom));
    return id;
}

exports.getIdByRandom = function(id, random, callback) {
    client.hget('randoms', id, function(err, reply) {
        if (reply) {
            var userRandom = JSON.parse(reply);
            if (userRandom.random == random) {
                callback(userRandom.id);
            } else {
                callback(null);
            }
        }
    });
}

exports.encryptTweet = function(user, tweet) {
    var message = new Buffer(tweet.tweet);
    tweet.tweet = exports.encryptWithUser(user, bignum.fromBuffer(message));
    return tweet;
}

/*
exports.prime = function(bits) {
    return bignum.prime(bits);
}

var RSA = function() {
    this.p = exports.prime(512);
    this.q = exports.prime(512);

    this.e = bignum(7);
    this.n = this.p.mul(this.q);
    this.phi = this.p.sub(1).mul(this.q.sub(1));
    this.d = this.e.invertm(this.phi);
}

exports.RSA = RSA;
exports.RSA.prototype.encrypt = function(num) {
    return bignum(num).powm(this.e, this.n);
}
exports.RSA.prototype.decrypt = function(num) {
    return bignum(num).powm(this.d, this.n);
}
*/

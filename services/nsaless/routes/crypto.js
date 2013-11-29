var bignum = require('bignum')

var getPrime = function(bits) {
    return bignum.prime(bits);
}

var pubKey = function(e, n) {
    return JSON.stringify({
        'e': e.toString(),
        'n': n.toString()
    })
}

var privKey = function(p, q) {
    return JSON.stringify({
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
        'priv': privKey(p, q)
    }
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

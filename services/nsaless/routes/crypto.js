var bignum = require('bignum')

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

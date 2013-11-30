#!/usr/bin/node

fs = require('fs');
bignum = require('bignum');

if (process.argv.length === 4)
{
    fs.readFile(process.argv[2], 'utf-8', function(err, data) {
        var priv = JSON.parse(new Buffer(data.toString(), 'base64').toString('utf-8'));
        console.log(priv);
        var p = bignum(priv.p);
        var q = bignum(priv.q);
        var e = bignum(priv.e);
        var n = p.mul(q);
        var phi = p.sub(1).mul(q.sub(1));
        var d = e.invertm(phi);
        console.log(bignum(process.argv[3]).powm(d, n).toString());
    });
}

var messages = {}

exports.create = function(req, res) {
  messages[req.body.id] = req.body.message;
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end(req.body.id);
}

exports.get = function(req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end(messages[req.params.id]);
}

var messages = [{id:0, message:'Huj'}]

exports.index = function(req, res) {
  res.render('index', {messages: messages});
}

exports.destroy = function(req, res) {
  delete messages[req.params.id];
  res.redirect('/');
}

exports.create = function(req, res) {
  messages.push({id:messages.length + 1, message: req.body.message})
  res.redirect('/');
}

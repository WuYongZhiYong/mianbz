router = require('express')()
bodyParser = require('body-parser')()
db = require('./db')
ef = require('errto')

module.exports = router;

router.post '/user',
  bodyParser,
  (req, res, next) ->
    user =
      username: req.body.username
      password: req.body.password
      email: req.body.email
    await db.get user.username, defer err, obj
    console.log err
    console.log err
    if (err.message.indexOf('not found') > -1)
      await db.put user.username, user, ef next, defer obj
      console.log(obj)
      res.json(success: true)
    else
      res.json(success: false)

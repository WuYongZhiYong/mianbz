router = require('express')()
bodyParser = require('body-parser')
db = require('./db')
ef = require('errto')

module.exports = router;

router.use bodyParser.json()
router.use bodyParser.urlencoded(extended: true)
router.post '/user',
  (req, res, next) ->
    user =
      username: req.body.username
      password: req.body.password
      email: req.body.email
    await db.userDb.get user.username, defer err, obj
    if (err and err.message.indexOf('not found') > -1)
      console.log 'register, %j', user
      await db.userDb.put user.username, user, ef next, defer obj
      res.json(success: true)
    else
      res.json(success: false)

router.post '/signin', (req, res, next) ->
  await db.userDb.get req.body.susername, defer err, obj
  console.log JSON.stringify(obj)
  if err or obj.password isnt req.body.spassword
    res.json(success: false)
  else
    res.json(success: true)

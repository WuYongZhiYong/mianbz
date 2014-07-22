router = require('express')()
bodyParser = require('body-parser')
db = require('./db')
ef = require('errto')
bcrypt = require('bcryptjs')
debug = require('debug')('api')

module.exports = router;

sha512 = (string) ->
  sha512sum = require('crypto').createHash('sha512')
  sha512sum.update(string, 'utf8')
  return sha512sum.digest('hex')

router.use bodyParser.json()
router.use bodyParser.urlencoded(extended: true)
router.post '/user',
  (req, res, next) ->
    user =
      username: req.body.username
      password: sha512(req.body.password)
      email: req.body.email
      salt: bcrypt.getSalt(req.body.password)
    await db.userDb.get user.username, defer err, obj
    if (err and err.message.indexOf('not found') > -1)
      console.log 'register, %j', user
      await db.userDb.put user.username, user, ef next, defer obj
      res.json(success: true)
    else
      res.json(success: false)

router.get '/salt', (req, res, next) ->
  await db.userDb.get req.query.username, defer err, obj
  return res.json {salt: '$2a$06$i7npE1FGF.c9tA4d1TG4Je'} if err or not obj.salt
  debug 'obj from db: %j', obj
  return res.json salt: obj.salt


passport = require('passport')
oauth2orize = require('oauth2orize')
server = oauth2orize.createServer()
server.exchange oauth2orize.exchange.password (client, username, password, scope, done) ->
  err = new Error 'invalid credential'
  err.status = 400
  err.code = 'invalid_request'
  await db.userDb.get username, defer err, obj
  return done err if err or not obj.password
  debug 'obj from db: %j', obj
  if obj.password is sha512(password)
    token = sha512(Math.random().toString())
    console.log token
    await db.tokenDb.put token, obj, ttl: 24*60*60*1000, ef done
    done null, token
  else
    done err

router.use passport.initialize()
passport.use new (require('passport-oauth2-client-password').Strategy) (clientId, clientSecret, done) ->
  if clientId is 'browser' and clientSecret is 'browser-client'
    done null, id: 'browser', name: 'browser'
  else
    err = new Error 'invalid client'
    err.code = 'unauthorized_client'
    err.status = 403
    done err

router.post '/signin', (req, res, next) ->
  await db.userDb.get req.body.username, defer err, obj
  return res.json {success: false} if err or not obj.password
  debug 'obj from db: %j', obj
  success = obj.password is sha512(req.body.password)
  res.json {success}

router.post '/token',
  passport.authenticate 'oauth2-client-password', session: false, failWithError: true
  server.token()

router.use server.errorHandler()

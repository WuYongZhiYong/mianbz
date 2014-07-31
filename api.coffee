router = require('express')()
bodyParser = require('body-parser')
db = require('./db')
ef = require('errto')
arity = require('fn-arity')
arity2 = arity.bind(null, 2)
bcrypt = require('bcryptjs')
debug = require('debug')('api')
config = require('config')
apiPass = require('api-pass')
superagent = require('superagent')

module.exports = router

sha512 = (string) ->
  sha512sum = require('crypto').createHash('sha512')
  sha512sum.update(string, 'utf8')
  return sha512sum.digest('hex')

router.use bodyParser.json()
router.use bodyParser.urlencoded(extended: true)
router.post '/user',
  (req, res, next) ->
    req.apiPass = true
    next()

router.get '/user/:username/salt',
  (req, res, next) ->
    req.apiPass = true
    next()

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
passport.use new (require('passport-http-bearer').Strategy) (token, done) ->
  await db.tokenDb.get token, defer err, obj
  console.log err
  done null, obj

router.post '/signin', (req, res, next) ->
  fail = () -> res.json {success: false}
  efn = ef.bind(null, fail)
  await superagent.get(config.backend + '/user?username=' + req.body.username)
    .end arity2 efn defer r
  debug 'obj from db: %j', r.body
  user = r.body
  console.log user.password
  console.log sha512(req.body.password)
  success = user.password is sha512(req.body.password)
  if success
    token = sha512(Math.random().toString())
    console.log token
    await db.tokenDb.put token, user, ttl: 24*60*60*1000, ef next
    res.cookie('mbzac', token, domain: '.mbz.io', maxAge: 12*60*60*1000)
  res.json {success}

router.post '/token',
  passport.authenticate 'oauth2-client-password', session: false, failWithError: true
  server.token()

router.use apiPass(config.backend)
router.use server.errorHandler()

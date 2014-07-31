fs = require('fs')
app = require('express')()
React = require('react')
db = require('./db')
browserify = require('browserify')
watchify = require('watchify')
htmlxify = require('htmlxify')
ef = require('errto')
extend = require('extend')
config = require('config')
superagent = require('superagent')
arity = require('fn-arity')
arity2 = arity.bind(null, 2)

env = process.env.NODE_ENV || 'development'

app.enable 'trust proxy'
app.disabled 'x-powered-by'
app.use require('morgan')()
app.get '/js/bundle.js', (req, res, next) ->
  res.setHeader('Content-Type', 'application/javascript; charset=utf-8')
  cache = null
  if app.get('env') == 'development'
    watchify(browserify(extend {debug: true}, watchify.args))
      .transform(require('icsify'))
      .transform(htmlxify())
      .add('./bundle.coffee')
      .bundle()
      .pipe(res)
  else
    return res.end(cache) if cache
    browserify()
      .transform(require('icsify'))
      .transform(htmlxify())
      .add('./bundle.coffee')
      .bundle ef next, (buf) ->
        cache = buf
        res.end(cache)

app.use(require('express/node_modules/serve-static')(__dirname + '/public'))

app.use '/api', require('./api')
app.use require('cookie-parser')()

app.get '/', (req, res, next) ->
  if (req.headers.host not in ['www.mianbizhe.com', 'mianbizhe.com', 'mian.bz', 'www.mian.bz', 'mbz.io:2014'])
    return next()
  res.set('content-type', 'text/html; charset=utf-8')
  res.sendfile(__dirname+'/index.html')

app.get '*', (req, res, next) ->
  reTld = /(\.mian\.bz|\.mbz\.io)(:\d+)?$/i
  if not req.headers.host?.match(reTld) or req.url.match(/^\/favicon\.ico/i)
    res.statusCode = 404
    return res.end('custom domain is currently not supported')
  console.log (req.cookies)
  username = req.headers.host.replace(reTld, '')
  domain = username + '.mian.bz'
  await superagent.get(config.backend + '/site?domain=' + domain)
    .end arity2 defer err, r
  return res.end('site not found') if r.error?.status == 404
  console.log(err.stack) if err
  console.log(JSON.stringify(err))
  console.log(r)
  res.sendfile(__dirname+'/entry.html')

app.listen(process.env.PORT || 2014)

fs = require('fs')
app = require('express')()
React = require('react')
db = require('./db')

env = process.env.NODE_ENV || 'development'

app.get '/js/bundle.js', (req, res, next) ->
  res.setHeader('Content-Type', 'application/javascript; charset=utf-8');
  require('browserify')()
    .add('./bundle.coffee')
    .external(['react', 'react-tag-mixin'])
    .transform(require('icsify'))
    .bundle(debug: env == 'development', bundleExternal: false).pipe(res)

app.get '/js/lib.js', (req, res, next) ->
  res.setHeader('Content-Type', 'application/javascript; charset=utf-8');
  src = if env is 'development' then './public/js/lib.debug.js' else './public/js/lib.js'
  fs.createReadStream(src).pipe(res)

app.use(require('express/node_modules/serve-static')(__dirname + '/public'))

app.use '/api', require('./api')

app.get '/', (req, res, next) ->
  if (req.headers.host not in ['www.mianbizhe.com', 'mianbizhe.com', 'mian.bz', 'www.mian.bz', 'mbz.io:2014'])
    return next()
  res.set('content-type', 'text/html; charset=utf-8');
  res.write('<!doctype html><html class="borderbox"><link rel="stylesheet" href="/bower_components/typo.css/typo.css" /><link rel="stylesheet" href="/components/lepture-yue.css/yue.css" /><link rel="stylesheet" href="/css/style.css" /><div id="sign-up-root-wrapper" class="container">')
  res.write(React.renderComponentToString(require('./components/frontpage')()))
  res.end('</div><script src="/js/lib.js"></script><script src="/js/bundle.js"></script></html>')

app.get '*', (req, res, next) ->
  reTld = /(\.mian\.bz|\.mbz\.io)(:\d+)?$/i
  if not req.headers.host?.match(reTld)
    res.statusCode(404)
    return res.end('custom domain is currently not supported')
  username = req.headers.host.replace(reTld, '')
  title = req.url.split('?')[0].split('/')[0].split('/').join(' ').trim()
  res.set('content-type', 'text/html; charset=utf-8');
  res.write('<!doctype html><html class="borderbox"><link rel="stylesheet" href="/bower_components/typo.css/typo.css" /><link rel="stylesheet" href="/components/lepture-yue.css/yue.css" /><link rel="stylesheet" href="/css/style.css" /><div id="root-wrapper" class="container">')
  res.write(React.renderComponentToString(require('./components/entry')(content: '#' + title)))
  res.end('</div><script src="/js/lib.js"></script><script src="/js/bundle.js"></script></html>')

app.listen(process.env.PORT || 2014)

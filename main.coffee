fs = require('fs')
app = require('express')()

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

app.get '/', (req, res, next) ->
  res.set('content-type', 'text/html; charset=utf-8');
  res.write('<!doctype html><html class="borderbox"><link rel="stylesheet" href="/bower_components/typo.css/typo.css" /><link rel="stylesheet" href="/components/lepture-yue.css/yue.css" /><link rel="stylesheet" href="/css/style.css" /><div id="sign-up-root-wrapper" class="container">')
  #res.write(React.renderComponentToString(require('./components/frontpage')()))
  res.end('</div><script src="/js/lib.js"></script><script src="/js/bundle.js"></script></html>')

app.use(require('express/node_modules/serve-static')(__dirname + '/public'))

app.use '/api', require('./api')

app.listen(process.env.PORT || 2014)

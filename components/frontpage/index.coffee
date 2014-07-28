React = require('react')
superagent = require('superagent')
ef = require('errto')
bcrypt = require('bcryptjs')
arity = require('fn-arity')
arity2 = arity.bind(null, 2)

module.exports = React.createClass
  onSubmit: (ev) ->
    efn = ef.bind null, (err) ->
      alert(err.message) if err

    ev.preventDefault()
    if not (@state.username and @state.password and @state.email)
      return alert '請填寫必要信息'
    await bcrypt.genSalt 6, efn defer salt
    return alert err.message if err
    console.log 'salt:', salt
    await bcrypt.hash @state.password, salt, efn defer hash
    @state.password = hash
    return alert err.message if err
    console.log 'hash:', hash
    obj =
      username: @state.username
      password: hash
      email: @state.email
    await superagent.post('/api/user')
      .type('form')
      .send(@state)
      .end arity2 efn defer r
    console.log r
    if r.status == 200
      alert(r.text)
  onSignin: (ev) ->
    efn = ef.bind null, (err) ->
      alert(err.message) if err

    ev.preventDefault()
    console.log @state
    await superagent.get('/api/salt?username='+@state.susername).end arity2 efn defer r
    console.log r
    await bcrypt.hash @state.spassword, r.body.salt, efn defer password
    console.log err
    console.log password
    await superagent.post('/api/token')
      .type('form')
      .send
        username: @state.susername
        password: password
        client_id: 'browser'
        client_secret: 'browser-client'
        grant_type: 'password'
      .end arity2 efn defer r
    console.log r
    if r.status == 200
      alert(r.text)
  changeUsername: (ev) ->
    @setState({username: ev.target.value})
  changePassword: (ev) ->
    @setState({password: ev.target.value})
  changeEmail: (ev) ->
    @setState({email: ev.target.value})
  changeSigninUsername: (ev) ->
    @setState({susername: ev.target.value})
  changeSigninPassword: (ev) ->
    @setState({spassword: ev.target.value})
  render: require('./tpl.htmlx')

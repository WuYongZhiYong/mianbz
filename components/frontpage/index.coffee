React = require('react')
TagMixin = require('react-tag-mixin')
superagent = require('superagent')
bcrypt = require('bcryptjs')

module.exports = React.createClass
  mixins: [TagMixin]
  onSubmit: (ev) ->
    ev.preventDefault()
    if not (@state.username and @state.password and @state.email)
      return alert '請填寫必要信息'
    await bcrypt.genSalt 6, defer err, salt
    return alert err.message if err
    console.log 'salt:', salt
    await bcrypt.hash @state.password, salt, defer err, hash
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
      .end defer r
    console.log r
    if (r.status == 200)
      alert(r.text)
  onSignin: (ev) ->
    ev.preventDefault()
    console.log @state
    await superagent.get('/api/salt?username='+@state.susername).end defer r
    console.log r
    await bcrypt.hash @state.spassword, r.body.salt, defer err, password
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
      .end defer r
    console.log r
    if (r.status == 200)
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
  render: ->
    @div '#signup.component-wrapper.container',
      @header '面壁者 MianBiZhe.com'
      @form onSubmit: @onSubmit,
        '註冊'
        @label null,
          @label '用戶名：'
          @input name: 'username', onChange: @changeUsername
          @span null, '.mian.bz'
        @label null,
          @label '密碼'
          @input name: 'password', onChange: @changePassword
        @label null,
          @label '郵箱'
          @input name: 'email', onChange: @changeEmail
        @button type: 'submit', '註冊'
      @aside null,
        '登入'
        @label null,
        @form onSubmit: @onSignin,
          @label null,
            @label '用戶名'
            @input name: 'username', onChange: @changeSigninUsername
          @label null,
            @label '密碼'
            @input name: 'password', onChange: @changeSigninPassword
          @button type: 'submit', '登入'

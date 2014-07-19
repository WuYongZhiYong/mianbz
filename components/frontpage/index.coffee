React = require('react')
TagMixin = require('react-tag-mixin')
superagent = require('superagent')

module.exports = React.createClass
  mixins: [TagMixin]
  onSubmit: (ev) ->
    ev.preventDefault()
    await superagent.post('/api/user')
      .type('form')
      .send(@state)
      .end defer r
    console.log r
    if (r.status == 200)
      alert(r.text)
  onSignin: (ev) ->
    console.log @state
    ev.preventDefault()
    await superagent.post('/api/signin')
      .type('form')
      .send(@state)
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

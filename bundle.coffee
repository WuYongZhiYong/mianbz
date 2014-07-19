React = require('react')

SignUp = require('./components/frontpage/index.coffee')
signUpRootWraper = document.getElementById('sign-up-root-wrapper')
React.renderComponent(SignUp(), signUpRootWraper) if signUpRootWraper

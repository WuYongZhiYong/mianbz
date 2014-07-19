React = require('react')

SignUp = require('./components/frontpage/index.coffee')
signUpRootWraper = document.getElementById('sign-up-root-wrapper')
React.renderComponent(SignUp(), signUpRootWraper) if signUpRootWraper

Entry = require('./components/entry/index.coffee')
entryRootWraper = document.getElementById('root-wrapper')
React.renderComponent(Entry(content: '#'+location.pathname.split('/').join(' ').trim()), entryRootWraper) if entryRootWraper

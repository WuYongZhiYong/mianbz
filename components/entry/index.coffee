React = require('react')
TagMixin = require('react-tag-mixin')
marked = require('marked')

module.exports = React.createClass
  mixins: [TagMixin]
  getDefaultProps: ->
    content: '#Hello World\nhere **there**'
  getInitialState: ->
    content: @props.content
    hideEditor: true
    showSaveButton: false
  contentChanged: (ev) ->
    content = @refs.editor.getDOMNode().value
    showSaveButton = content isnt @props.content
    @setState({content, showSaveButton})
  hideEditor: ->
    @setState(hideEditor: yes)
  showEditor: ->
    @setState(hideEditor: no)
  render: require('./tpl.htmlx')

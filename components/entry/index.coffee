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
  contentChanged: (ev) ->
    @setState(content: @refs.editor.getDOMNode().value)
  hideEditor: ->
    @setState(hideEditor: yes)
  showEditor: ->
    @setState(hideEditor: no)
  render: ->
    @div '.component-wrapper',
      @div
        id: 'content'
        className: 'typo yue',
        onMouseEnter: @showEditor
        dangerouslySetInnerHTML: __html: marked(@state.content)
      @div className: 'editor-wrapper ' + (if @state.hideEditor then 'hide' else ''),
        @div '.container',
          @textarea
            id: 'editor',
            onMouseLeave: @hideEditor,
            onChange: @contentChanged,
            ref: 'editor',
            className: 'typo yue'
            defaultValue: @props.content

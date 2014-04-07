toggleQuotes = (editor) ->
  cursors = editor.getCursors()

  positions = []

  for cursor in cursors
    do (cursor) ->
      positions.push(position = cursor.getBufferPosition())
      toggleQuoteAtPosition(editor, position)

  # reset cursors to where they were - first destroy all, then add them back in
  # at their original places
  cursor.destroy() for cursor in editor.getCursors()
  editor.addCursorAtBufferPosition position for position in positions

toggleQuoteAtPosition = (editor, position) ->
  range = editor.displayBuffer.bufferRangeForScopeAtPosition('.string.quoted', position)
  return unless range?

  text = editor.getTextInBufferRange(range)
  quoteCharacter = text[0]
  oppositeQuoteCharacter = getOppositeQuote(quoteCharacter)
  quoteRegex = new RegExp(quoteCharacter, 'g')
  escapedQuoteRegex = new RegExp("\\\\#{quoteCharacter}", 'g')
  oppositeQuoteRegex = new RegExp(oppositeQuoteCharacter, 'g')

  newText = text
    .replace(oppositeQuoteRegex, "\\#{oppositeQuoteCharacter}")
    .replace(escapedQuoteRegex, quoteCharacter)
  newText = oppositeQuoteCharacter + newText[1...-1] + oppositeQuoteCharacter

  editor.setTextInBufferRange(range, newText)

getOppositeQuote = (quoteCharacter) ->
  if quoteCharacter is '"'
    "'"
  else
    '"'

module.exports =
  activate: ->
    atom.workspaceView.command 'toggle-quotes:toggle', '.editor', ->
      paneItem = atom.workspaceView.getActivePaneItem()
      toggleQuotes(paneItem)

  toggleQuotes: toggleQuotes

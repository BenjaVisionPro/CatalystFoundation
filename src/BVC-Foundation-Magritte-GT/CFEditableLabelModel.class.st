"I am responsible for Foundation editable-label focus semantics. Read-only focus remains ordinary Bloc focus for selection presentation, while editor cursor focus is only propagated in editable mode."

Class {
	#name : 'CFEditableLabelModel',
	#superclass : 'BrEditableLabelModel',
	#category : 'BVC-Foundation-Magritte-GT-View Models',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'View Models'
}

{ #category : 'private - focus' }
CFEditableLabelModel >> onGotFocus [
	isFocused := true.

	self editorMode isEditable ifFalse: [ ^ self ].

	self processCursorEnterEvents.
	self enqueueCommand: (self newFocusChangedCommand hasFocus: true)
]

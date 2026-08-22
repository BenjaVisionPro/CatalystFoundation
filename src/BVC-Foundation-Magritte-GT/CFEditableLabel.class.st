"
I am Foundation's in-place editable label. I retain BrEditableLabel's complete editor and edition lifecycle while hiding the rendered caret in read-only focus.
"
Class {
	#name : 'CFEditableLabel',
	#superclass : 'BrEditableLabel',
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'private - cursor presentation' }
CFEditableLabel >> hideRenderedCursors [
	self allChildrenBreadthFirstDo: [ :anElement |
		(anElement respondsTo: #hideCursors)
			ifTrue: [ anElement hideCursors ] ]
]

{ #category : 'initialization' }
CFEditableLabel >> initialize [
	super initialize.

	self
		when: BlFocusEvent
		do: [ :anEvent |
			self isReadOnly ifTrue: [ self hideRenderedCursors ] ]
]

{ #category : 'private - cursor presentation' }
CFEditableLabel >> showRenderedCursors [
	self allChildrenBreadthFirstDo: [ :anElement |
		(anElement respondsTo: #showCursors)
			ifTrue: [ anElement showCursors ] ]
]

{ #category : 'api  - mode' }
CFEditableLabel >> switchToEditor [
	super switchToEditor.
	self showRenderedCursors
]

{ #category : 'api  - mode' }
CFEditableLabel >> switchToLabel [
	super switchToLabel.
	self hideRenderedCursors
]

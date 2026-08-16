"I am Foundation's in-place editable label. A single click gives me ordinary Bloc focus without an editor caret; double-click or Enter uses Brick's normal editable-label lifecycle."

Class {
	#name : 'CFEditableLabel',
	#superclass : 'BrEditableLabel',
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'initialization' }
CFEditableLabel >> initialize [
	super initialize.

	self editor: CFEditableLabelModel new.
	self switchToLabel
]

"I provide executable examples for Foundation's editable-label interaction contract."

Class {
	#name : 'CFEditableLabelExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples' }
CFEditableLabelExamples >> editableLabel [
	<gtExample>
	| aLabel |
	aLabel := CFEditableLabel new
		aptitude: BrGlamorousEditableLabelAptitude new;
		text: 'Editable';
		yourself.

	self assert: aLabel editor class equals: CFEditableLabelModel.
	self assert: aLabel isReadOnly.
	^ aLabel
]

{ #category : 'examples' }
CFEditableLabelExamples >> editableLabelCanEnterEditorMode [
	<gtExample>
	| aLabel |
	aLabel := self editableLabel.
	aLabel switchToEditor.

	self assert: aLabel isEditable.
	^ aLabel
]

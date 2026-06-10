Class {
	#name : 'CFMaToOneElementStencilBuilder',
	#superclass : 'GtMagritteListElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaToOneElementStencilBuilder >> buildDefault [
	<return: #BlElement>
	| anElement |
	(self memento isNil or: [ self description isNil ])
		ifTrue: [ ^ BrFrame new fitContent ].

	anElement := self description isEmbedded
		ifTrue: [ CFMaBuilderUtility
			newEmbeddedToOneMemento: self memento
			using: self description ]
		ifFalse: [ CFMaBuilderUtility
			newToOneListMemento: self memento
			using: self description ].

	self form ifNotNil: [ :aForm |
		aForm matchParent.
		CFMaBuilderUtility
			installRelationEditorNavigationShortcutsOn: anElement
			form: aForm ].

	^ GtMagritteValidatedFieldElement new
		memento: self memento
		description: self description
		element: anElement;
		hMatchParent;
		vFitContent;
		yourself
]

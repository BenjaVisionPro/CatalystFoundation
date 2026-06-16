Class {
	#name : 'CFMaColumnedToOneElementStencilBuilder',
	#superclass : 'GtMagritteListElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaColumnedToOneElementStencilBuilder >> buildDefault [
	<return: #BlElement>
	| anElement |
	(self memento isNil or: [ self description isNil ])
		ifTrue: [ ^ BrFrame new fitContent ].

	anElement := CFMaBuilderUtility
		newColumnedToOneListMemento: self memento
		using: self description.

	self form ifNotNil: [ :aForm | aForm matchParent ].

	^ GtMagritteValidatedFieldElement new
		memento: self memento
		description: self description
		element: anElement;
		hMatchParent;
		vFitContentLimited;
		yourself
]

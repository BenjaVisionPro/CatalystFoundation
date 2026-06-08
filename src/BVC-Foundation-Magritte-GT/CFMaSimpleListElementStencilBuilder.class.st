Class {
	#name : 'CFMaSimpleListElementStencilBuilder',
	#superclass : 'GtMagritteListElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaSimpleListElementStencilBuilder >> buildDefault [
	<return: #BlElement>

	| aListElement |
	(self memento isNil or: [ self description isNil ])
		ifTrue: [ ^ BrFrame new fitContent ].

	aListElement := CFMaBuilderUtility
		newSimpleListMemento: self memento
		using: self description.

	self form ifNotNil: [ :aForm | aForm matchParent ].

	^ GtMagritteValidatedFieldElement new
		memento: self memento
		description: self description
		element: aListElement;
		hMatchParent;
		vFitContent;
		yourself
]

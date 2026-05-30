Class {
	#name : 'CFMaListElementStencilBuilder',
	#superclass : 'GtMagritteListElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaListElementStencilBuilder >> buildDefault [
	<return: #BlElement>
	| aFlowElement |
	(self memento isNil or: [ self description isNil ])
		ifTrue: [ ^ BrFrame new fitContent ].

	aFlowElement := CFMaBuilderUtility
		newFlowListMemento: self memento
		using: self description.
	aFlowElement constraintsDo: [ :c | c minHeight: 200 ].

	self form ifNotNil: [ :aForm | aForm matchParent ].

	^ CFMaValidatedFieldElement new
		memento: self memento
		description: self description
		element: aFlowElement;
		hMatchParent;
		vFitContent;
		yourself
]

"I am responsible for presenting a to-many relation as a simple Foundation list editor."

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
	aFlowElement
		hMatchParent;
		vFitContent.
	^ aFlowElement
]

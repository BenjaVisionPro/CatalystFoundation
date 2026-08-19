"I am responsible for presenting a to-one relation as a columned Foundation list editor."

Class {
	#name : 'CFMaColumnedToOneElementStencilBuilder',
	#superclass : 'GtMagritteListElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaColumnedToOneElementStencilBuilder >> buildDefault [
	<return: #BlElement>
	(self memento isNil or: [ self description isNil ])
		ifTrue: [ ^ BrFrame new fitContent ].

	^ (CFMaBuilderUtility
		newColumnedListToOneMemento: self memento
		using: self description)
		hMatchParent;
		vFitContentLimited;
		yourself
]

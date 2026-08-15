"I am responsible for creating editable identity item view models inside their parent Foundation Magritte transaction."

Class {
	#name : 'CFMaIdentityItemViewModelStencilBuilder',
	#superclass : 'GtMagritteModelStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaIdentityItemViewModelStencilBuilder >> buildDefault [
	| aChildMemento |
	aChildMemento := self memento
		ifNil: [ CFMaMemento model: self model ]
		ifNotNil: [
			self memento
				childMementoFor: self model
				inRelation: self description ].

	^ CFMaIdentityItemViewModel
		object: self model
		memento: aChildMemento
]

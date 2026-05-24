Class {
	#name : 'CFMaAddItemViewModel',
	#superclass : 'GtMagritteAddItemViewModel',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - adding' }
CFMaAddItemViewModel >> addItem: aNewItem from: anElement [
	| anExistingItems aNewItems |
	self memento ifNil: [ ^ self ].
	self description ifNil: [ ^ self ].

	anExistingItems := self memento readUsing: self description.
	anExistingItems ifNil: [ anExistingItems := #() ].
	aNewItems := anExistingItems copyWith: aNewItem.

	GtMagritteBuilderUtility
		write: aNewItems
		using: self description
		memento: self memento
		element: anElement
]

{ #category : 'converting' }
CFMaAddItemViewModel >> asElement [
	self description ifNil: [ ^ super asElement ].

	self description cfAddItemStencil
		ifNotNil: [ :aStencil |
			(aStencil respondsTo: #arguments:)
				ifTrue: [ aStencil arguments: { self } ].
			^ aStencil create asElement ].

	^ super asElement
]

{ #category : 'api - adding' }
CFMaAddItemViewModel >> createAndAddFrom: anElement [
	self stencil ifNil: [ ^ self ].

	self
		addItem: self stencil create
		from: anElement
]

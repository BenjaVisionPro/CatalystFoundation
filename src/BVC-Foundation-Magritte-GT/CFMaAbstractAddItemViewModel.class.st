Class {
	#name : 'CFMaAbstractAddItemViewModel',
	#superclass : 'GtMagritteAddItemViewModel',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'private - instance creation' }
CFMaAbstractAddItemViewModel >> configureParentForNewItem: anObject [
	self description setParentOnNewItems
		ifTrue: [ anObject parent: self memento model ].

	^ anObject
]

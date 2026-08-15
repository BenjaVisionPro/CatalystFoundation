"I represent a selection context that currently contains focus and propagate that state to its descendants."

Class {
	#name : 'CFMaActiveSelectionState',
	#superclass : 'BlElementUniqueState',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'printing' }
CFMaActiveSelectionState >> printOn: aStream [
	aStream nextPutAll: 'cfMaActiveSelection'
]

{ #category : 'accessing' }
CFMaActiveSelectionState >> priority [
	"Use the same precedence as the built-in focused state so composed
	selected + active-selection styles apply after the standard selected style."
	^ BlElementState focused priority
]

{ #category : 'testing' }
CFMaActiveSelectionState >> shouldPropagateToChildren [
	^ true
]

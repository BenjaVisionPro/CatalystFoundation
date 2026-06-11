Class {
	#name : 'CFMaFocusWithinState',
	#superclass : 'BlElementUniqueState',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'printing' }
CFMaFocusWithinState >> printOn: aStream [
	aStream nextPutAll: 'cfMaFocusWithin'
]

{ #category : 'accessing' }
CFMaFocusWithinState >> priority [
	"Use the same precedence as the built-in focused state so composed
	selected + focus-within styles apply after the standard selected style."
	^ BlElementState focused priority
]

{ #category : 'testing' }
CFMaFocusWithinState >> shouldPropagateToChildren [
	^ true
]

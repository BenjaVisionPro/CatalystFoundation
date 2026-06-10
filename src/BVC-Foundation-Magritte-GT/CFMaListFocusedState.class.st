Class {
	#name : 'CFMaListFocusedState',
	#superclass : 'BlElementUniqueState',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'printing' }
CFMaListFocusedState >> printOn: aStream [
	aStream nextPutAll: 'cfMaListFocused'
]

{ #category : 'accessing' }
CFMaListFocusedState >> priority [
	"Use the same precedence as the built-in focused state so composed
	selected + list-focused styles apply after the standard selected style."
	^ BlElementState focused priority
]

{ #category : 'testing' }
CFMaListFocusedState >> shouldPropagateToChildren [
	^ true
]

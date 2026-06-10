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
	^ UserPriority
]

{ #category : 'testing' }
CFMaListFocusedState >> shouldPropagateToChildren [
	^ true
]

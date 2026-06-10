Class {
	#name : 'CFMaRelationEditorActiveState',
	#superclass : 'BlElementUniqueState',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'printing' }
CFMaRelationEditorActiveState >> printOn: aStream [
	aStream nextPutAll: 'relationEditorActive'
]

{ #category : 'accessing' }
CFMaRelationEditorActiveState >> priority [
	^ UserPriority
]

{ #category : 'testing' }
CFMaRelationEditorActiveState >> shouldPropagateToChildren [
	^ true
]

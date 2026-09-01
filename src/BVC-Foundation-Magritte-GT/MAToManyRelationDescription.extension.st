Extension { #name : 'MAToManyRelationDescription' }

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> relationBodyInsets [
	^ self
		propertyAt: #cfMaRelationBodyInsets
		ifAbsent: [ BlInsets all: 6 ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> relationBodyInsets: anInsets [
	self propertyAt: #cfMaRelationBodyInsets put: anInsets
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> relationGridItemInsets [
	^ self
		propertyAt: #cfMaRelationGridItemInsets
		ifAbsent: [ BlInsets all: 4 ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> relationGridItemInsets: anInsets [
	self propertyAt: #cfMaRelationGridItemInsets put: anInsets
]

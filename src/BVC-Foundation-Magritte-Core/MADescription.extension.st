Extension { #name : 'MADescription' }

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfCategory [
	^ self propertyAt: self cfCategorySymbol ifAbsent: [ nil ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfCategory: aValue [
	^ self propertyAt: self cfCategorySymbol put: aValue
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfCategorySymbol [
	^ #cfCategory
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfSerializable [
	^ self
		propertyAt: self cfSerializableSymbol
		ifAbsent: [ false ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfSerializable: aBoolean [
	^ self propertyAt: self cfSerializableSymbol put: aBoolean
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfSerializableSymbol [
	^ #cfSerializable
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> path [
	^ self propertyAt: #cfPath ifAbsent: [ #() ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> path: aCollection [
	^ self propertyAt: #cfPath put: aCollection
]


{ #category : '*bvc-foundation-magritte-core' }
MADescription >> icon [
	^ self propertyAt: #cfIcon ifAbsent: [ nil ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> icon: anIcon [
	^ self propertyAt: #cfIcon put: anIcon
]


{ #category : '*bvc-foundation-magritte-core' }
MADescription >> iconBackground [
	^ self propertyAt: #cfIconBackground ifAbsent: [ nil ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> iconBackground: aColor [
	^ self propertyAt: #cfIconBackground put: aColor
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> iconFor: anObject [
	| aValue |
	aValue := self icon.
	aValue ifNil: [ ^ nil ].
	^ (aValue isBlock or: [ aValue isSymbol ])
		ifTrue: [ aValue cull: anObject cull: self ]
		ifFalse: [ aValue ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> iconBackgroundFor: anObject [
	| aValue |
	aValue := self iconBackground.
	aValue ifNil: [ ^ nil ].
	^ (aValue isBlock or: [ aValue isSymbol ])
		ifTrue: [ aValue cull: anObject cull: self ]
		ifFalse: [ aValue ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> badges [
	^ self propertyAt: #cfBadges ifAbsent: [ #() ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> badges: aValue [
	^ self propertyAt: #cfBadges put: aValue
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> badgesFor: anObject [
	| aValue |
	aValue := self badges.
	^ (aValue isBlock or: [ aValue isSymbol ])
		ifTrue: [ aValue cull: anObject cull: self ]
		ifFalse: [ aValue ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> information [
	^ self propertyAt: #cfInformation ifAbsent: [ nil ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> information: aValue [
	^ self propertyAt: #cfInformation put: aValue
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> informationFor: anObject [
	| aValue |
	aValue := self information.
	aValue ifNil: [ ^ nil ].
	^ (aValue isBlock or: [ aValue isSymbol ])
		ifTrue: [ aValue cull: anObject cull: self ]
		ifFalse: [ aValue ]
]


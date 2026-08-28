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
MADescription >> categories [
	^ self propertyAt: #cfCategories ifAbsent: [ #() ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> categories: aCollection [
	^ self
		propertyAt: #cfCategories
		put: (aCollection ifNil: [ #() ] ifNotNil: [ aCollection asArray ])
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> fieldConfigure [
	^ self propertyAt: #cfFieldConfigure ifAbsent: [ nil ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> fieldConfigure: aBlock [
	^ self propertyAt: #cfFieldConfigure put: aBlock
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> configureField: aFieldConfiguration [
	self fieldConfigure ifNotNil: [ :aBlock | aBlock cull: aFieldConfiguration ].
	^ aFieldConfiguration
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
MADescription >> iconFor: anObject [
	| aValue |
	aValue := self icon.
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


{ #category : '*bvc-foundation-magritte-core' }
MADescription >> enablementCondition [
	^ self propertyAt: #cfEnablementCondition ifAbsent: [ nil ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> enabledWhen: aDescription equals: anObject [
	^ self
		propertyAt: #cfEnablementCondition
		put: (CFMaEnablementCondition description: aDescription equals: anObject)
]

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
MADescription >> fieldMetadataFor: anObject [
	| contextualMetadata |
	contextualMetadata := anObject fieldMetadataFor: self.
	^ CFFieldMetadata new
		icon: (contextualMetadata icon ifNil: [ self icon ]);
		iconBackground: (contextualMetadata iconBackground ifNil: [ self iconBackground ]);
		badges: contextualMetadata badges;
		information: contextualMetadata information;
		yourself
]

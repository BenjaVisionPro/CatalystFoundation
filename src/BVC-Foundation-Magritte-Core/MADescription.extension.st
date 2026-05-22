Extension { #name : 'MADescription' }

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfCategory [
	self propertyAt: self cfCategorySymbol ifAbsent: [ nil ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfCategory: aValue [
	self propertyAt: self cfCategorySymbol put: aValue
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfCategorySymbol [
	^ #cfCategory
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfSerializable [
	self
		propertyAt: self cfSerializableSymbol
		ifAbsent: [ false ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfSerializableSymbol [
	^ #cfSerializable
]

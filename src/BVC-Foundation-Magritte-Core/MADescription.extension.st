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
	^ self
		propertyAt: self cfSerializableSymbol
		ifAbsent: [ false ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfSerializableSymbol [
	^ #cfSerializable
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> beCompactComment [
	self cfCompactSlot: #comment
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> beCompactIcon [
	self cfCompactSlot: #icon
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> beCompactTitle [
	self cfCompactSlot: #title
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfCompactSlot [
	^ self propertyAt: #cfCompactSlot ifAbsent: [ #comment ]
]

{ #category : '*bvc-foundation-magritte-core' }
MADescription >> cfCompactSlot: aSymbol [
	self propertyAt: #cfCompactSlot put: aSymbol
]

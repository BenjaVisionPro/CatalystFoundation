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
MARelationDescription >> beCFConfigurationEmbedded [
	self cfConfigurationEmbedded: true
]

{ #category : '*bvc-foundation-magritte-core' }
MARelationDescription >> beCFConfigurationReferenced [
	self cfConfigurationEmbedded: false
]

{ #category : '*bvc-foundation-magritte-core' }
MARelationDescription >> cfConfigurationEmbedded [
	"Configuration relationships are structural by default. Mark a relation
	as referenced when it should not be copied, validated, or targeted as part
	of the configuration graph."
	^ self
		propertyAt: self cfConfigurationEmbeddedSymbol
		ifAbsent: [ true ]
]

{ #category : '*bvc-foundation-magritte-core' }
MARelationDescription >> cfConfigurationEmbedded: aBoolean [
	^ self propertyAt: self cfConfigurationEmbeddedSymbol put: aBoolean
]

{ #category : '*bvc-foundation-magritte-core' }
MARelationDescription >> cfConfigurationEmbeddedSymbol [
	^ #cfConfigurationEmbedded
]

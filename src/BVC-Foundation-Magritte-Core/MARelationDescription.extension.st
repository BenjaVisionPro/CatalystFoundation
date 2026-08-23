Extension { #name : 'MARelationDescription' }

{ #category : '*bvc-foundation-magritte-core' }
MARelationDescription >> configureField: aFieldConfiguration [
	aFieldConfiguration beList.
	^ super configureField: aFieldConfiguration
]

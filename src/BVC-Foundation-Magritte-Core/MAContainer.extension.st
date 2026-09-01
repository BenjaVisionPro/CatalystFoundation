Extension { #name : 'MAContainer' }

{ #category : '*bvc-foundation-magritte-core' }
MAContainer >> compactIdentityReference [
	^ self propertyAt: #compactIdentityReference ifAbsent: [ nil ]
]

{ #category : '*bvc-foundation-magritte-core' }
MAContainer >> compactIdentityReference: aReferenceDescription [
	self propertyAt: #compactIdentityReference put: aReferenceDescription
]

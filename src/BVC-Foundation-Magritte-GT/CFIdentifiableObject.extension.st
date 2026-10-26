Extension { #name : #CFIdentifiableObject }

{ #category : '*BVC-Foundation-Magritte-GT' }
CFIdentifiableObject >> compactIdentityReference [
	^ self iconDescription, self identifierDescription
]

{ #category : '*BVC-Foundation-Magritte-GT' }
CFIdentifiableObject >> descriptionContainerCompactIdentity: aDescription [
	<magritteContainer>
	aDescription compactIdentityReference ifNil: [
		aDescription compactIdentityReference: self compactIdentityReference ].
	^ aDescription
]

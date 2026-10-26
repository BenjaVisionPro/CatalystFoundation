Extension { #name : #CFLabelledObject }

{ #category : '*BVC-Foundation-Magritte-GT' }
CFLabelledObject >> compactIdentityReference [
	^ self iconDescription, self labelDescription, self identifierDescription
]

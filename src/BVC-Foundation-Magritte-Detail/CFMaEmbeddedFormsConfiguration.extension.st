Extension { #name : 'CFMaEmbeddedFormsConfiguration' }

{ #category : '*bvc-foundation-magritte-detail' }
CFMaEmbeddedFormsConfiguration >> addToManyRelationUsing: aDescription toDetailPresentation: aPresentation [
	^ aPresentation addToManyEmbeddedUsing: aDescription
]

{ #category : '*bvc-foundation-magritte-detail' }
CFMaEmbeddedFormsConfiguration >> addToOneRelationUsing: aDescription toDetailPresentation: aPresentation [
	^ aPresentation addToOneEmbeddedUsing: aDescription
]

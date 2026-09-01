Extension { #name : 'CFMaListConfiguration' }

{ #category : '*bvc-foundation-magritte-detail' }
CFMaListConfiguration >> addToManyRelationUsing: aDescription toDetailPresentation: aPresentation [
	^ aPresentation addListToManyUsing: aDescription
]

{ #category : '*bvc-foundation-magritte-detail' }
CFMaListConfiguration >> addToOneRelationUsing: aDescription toDetailPresentation: aPresentation [
	^ aPresentation addToOneListUsing: aDescription
]

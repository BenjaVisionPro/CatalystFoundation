Extension { #name : 'CFMaFieldRepresentationConfiguration' }

{ #category : '*bvc-foundation-magritte-detail' }
CFMaFieldRepresentationConfiguration >> addNumberUsing: aDescription toDetailPresentation: aPresentation [
	^ self error: 'Unsupported number field representation'
]

{ #category : '*bvc-foundation-magritte-detail' }
CFMaFieldRepresentationConfiguration >> addSingleOptionUsing: aDescription toDetailPresentation: aPresentation [
	^ self error: 'Unsupported single-option field representation'
]

{ #category : '*bvc-foundation-magritte-detail' }
CFMaFieldRepresentationConfiguration >> addToManyRelationUsing: aDescription toDetailPresentation: aPresentation [
	^ self error: 'Unsupported to-many relation representation'
]

{ #category : '*bvc-foundation-magritte-detail' }
CFMaFieldRepresentationConfiguration >> addToOneRelationUsing: aDescription toDetailPresentation: aPresentation [
	^ self error: 'Unsupported to-one relation representation'
]

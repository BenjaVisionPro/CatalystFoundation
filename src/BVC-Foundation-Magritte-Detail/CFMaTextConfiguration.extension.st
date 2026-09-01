Extension { #name : 'CFMaTextConfiguration' }

{ #category : '*bvc-foundation-magritte-detail' }
CFMaTextConfiguration >> addNumberUsing: aDescription toDetailPresentation: aPresentation [
	^ aPresentation addTextNumberUsing: aDescription
]

{ #category : '*bvc-foundation-magritte-detail' }
CFMaTextConfiguration >> addSingleOptionUsing: aDescription toDetailPresentation: aPresentation [
	^ aPresentation
		addPopupSingleOptionUsing: aDescription
		display: [ :aValue | aDescription displayStringFor: aValue ]
]

Extension { #name : 'CFMaPopupConfiguration' }

{ #category : '*bvc-foundation-magritte-detail' }
CFMaPopupConfiguration >> addNumberUsing: aDescription toDetailPresentation: aPresentation [
	^ aPresentation addNumberPopupUsing: aDescription configuration: self
]

{ #category : '*bvc-foundation-magritte-detail' }
CFMaPopupConfiguration >> addSingleOptionUsing: aDescription toDetailPresentation: aPresentation [
	^ aPresentation
		addPopupSingleOptionUsing: aDescription
		display: (self displayBlock
			ifNil: [ [ :aValue | aDescription displayStringFor: aValue ] ])
]

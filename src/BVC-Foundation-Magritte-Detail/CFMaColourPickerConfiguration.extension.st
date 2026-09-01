Extension { #name : 'CFMaColourPickerConfiguration' }

{ #category : '*bvc-foundation-magritte-detail' }
CFMaColourPickerConfiguration >> addSingleOptionUsing: aDescription toDetailPresentation: aPresentation [
	^ aPresentation
		addSingleOptionColourPickerUsing: aDescription
		configuration: self
]

Extension { #name : 'CFMaFormShowcase' }

{ #category : '*bvc-foundation-magritte-detail-examples' }
CFMaFormShowcase >> exampleDetailElement [
	<gtExample>
	| aDescription aMemento |
	aDescription := self magritteDescription.
	aDescription blocPresentationStencil: [ :theMemento |
		CFMaDetailPresentation new ].
	aMemento := CFMaMemento model: self description: aDescription.
	^ (CFMaViewModel forObject: self memento: aMemento) asElement
]

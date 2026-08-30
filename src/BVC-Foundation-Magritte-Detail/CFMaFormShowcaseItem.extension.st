Extension { #name : 'CFMaFormShowcaseItem' }

{ #category : '*BVC-Foundation-Magritte-Detail' }
CFMaFormShowcaseItem >> descriptionContainerDetail: aDescription [
	<magritteContainer>
	^ aDescription
		blocPresentationStencil: [ :aMemento | CFMaDetailPresentation new ];
		yourself
]

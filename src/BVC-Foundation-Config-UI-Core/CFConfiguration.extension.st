Extension { #name : 'CFConfiguration' }

{ #category : '*BVC-Foundation-Config-UI-Core' }
CFConfiguration >> asAtelier [
	"Atelier is the supported configuration authoring entry. Its Foundation
	memento owns staged edits; the configuration container selects Detail."
	^ CFAtelierViewModel forObject: self
]

{ #category : '*BVC-Foundation-Config-UI-Core' }
CFConfiguration >> descriptionContainerDetail: aDescription [
	<magritteContainer>
	"Select Detail for configuration forms without changing the generic default."
	^ aDescription
		blocPresentationStencil: [ :aMemento | CFMaDetailPresentation new ];
		yourself
]

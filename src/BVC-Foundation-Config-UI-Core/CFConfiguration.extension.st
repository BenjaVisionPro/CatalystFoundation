Extension { #name : 'CFConfiguration' }

{ #category : '*BVC-Foundation-Config-UI-Core' }
CFConfiguration >> asAtelier [
	"The palette offers assessed, Motion-backed previews only. Magritte still
	owns editing; copied planner choices are never insertion operations."
	| atelier palette editingContext preview |
	atelier := CFAtelierViewModel forObject: self.
	palette := CFAtelierPalette new.
	CFConfigurationLibrary discovered assets do: [ :asset |
		palette add: (CFAtelierPaletteItem
			label: asset label
			provider: (CFAtelierExistingObjectProvider object: asset)) ].
	atelier presentationDo: [ :presentation |
		editingContext := presentation memento.
		preview ifNotNil: [ preview editingContext: editingContext ] ].
	atelier palette: palette.
	atelier paletteElementFactory: [
		preview := CFConfigurationPlacementPreviewElement new.
		preview editingContext: editingContext.
		preview ].
	^ atelier
]

{ #category : '*BVC-Foundation-Config-UI-Core' }
CFConfiguration >> descriptionContainerDetail: aDescription [
	<magritteContainer>
	"Select Detail for configuration forms without changing the generic default."
	^ aDescription
		blocPresentationStencil: [ :aMemento | CFMaDetailPresentation new ];
		yourself
]

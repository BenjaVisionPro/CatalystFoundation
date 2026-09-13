Extension { #name : 'GtTreePagerElement' }

{ #category : '*BVC-Foundation-Atelier' }
GtTreePagerElement >> beAtelierOverlay [
	self
		background: Color transparent;
		padding: BlInsets empty;
		preventMouseEvents.
	scrollbarElement visibility: BlVisibility gone.
	panesElement
		preventMouseEvents;
		when: GtTreePagerFlowPaneElementsChanged
		do: [ :anEvent | self updateAtelierOverlayPaneElements ].
	self updateAtelierOverlayPaneElements
]

{ #category : '*BVC-Foundation-Atelier' }
GtTreePagerElement >> updateAtelierOverlayPaneElements [
	panesElement children do: [ :eachElement |
		eachElement graph isNode ifTrue: [ eachElement beAtelierOverlay ] ]
]

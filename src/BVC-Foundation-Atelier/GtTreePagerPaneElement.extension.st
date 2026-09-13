Extension { #name : 'GtTreePagerPaneElement' }

{ #category : '*BVC-Foundation-Atelier' }
GtTreePagerPaneElement >> beAtelierOverlay [
	self
		background: Color transparent;
		padding: BlInsets empty;
		preventMouseEvents.
	self hideTopRightElement.
	contentContainer
		background: Color transparent;
		preventMouseEvents.
	followingsElement preventMouseEvents.
	contentElement
		background: Color transparent;
		preventMouseEvents
]

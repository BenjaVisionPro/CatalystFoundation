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
		effect: BlNullEffect new;
		addAptitude: (BrStyleCommonAptitude new
			default: [ :aStyle | aStyle effect: BlNullEffect new ];
			focused: [ :aStyle | aStyle effect: BlNullEffect new ]);
		preventMouseEvents
]

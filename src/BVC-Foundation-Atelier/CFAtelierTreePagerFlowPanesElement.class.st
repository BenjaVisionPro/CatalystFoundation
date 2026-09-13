"I create the panes for Atelier's Tree Pager.

GT's flow element hard-codes GtTreePagerPaneElement in its pane factory. Atelier needs the same navigation, caching, resizing and layout machinery with CFAtelierTreePagerPaneElement as the pane class. This is the construction seam; panes are not restyled after insertion."
Class {
	#name : 'CFAtelierTreePagerFlowPanesElement',
	#superclass : 'GtTreePagerFlowPanesElement',
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'private - updating' }
CFAtelierTreePagerFlowPanesElement >> newNodeElementForPaneModel: aPaneModel [
	| aPaneElement |
	aPaneElement := CFAtelierTreePagerPaneElement new.
	aPaneElement
		contentElementDo: [ :aContentElement |
			aContentElement
				navigationContext: (GtTreePagerPaneNavigationContext new
					pagerElement: self;
					paneElement: aPaneElement);
				addAptitude: (BrGlamorousWithHorizontalResizerAptitude new
					beRight;
					resizerDo: [ :aResizer |
						aPaneElement
							addAptitude: (BrLazyStyleCommonAptitude new
								default: [ :aStyle |
									aStyle
										do: [ :aWidget |
											aPaneElement hideToolbarElements.
											aResizer visibility: BlVisibility hidden ]
										after: [ :aWidget |  ] ];
								hovered: [ :aStyle |
									aStyle
										do: [ :aWidget |
											aPaneElement showToolbarElements.
											aResizer visibility: BlVisibility visible ]
										after: [ :aWidget |
											aPaneElement hideToolbarElements.
											aResizer visibility: BlVisibility hidden ] ]).

						aResizer
							when: BlDoubleClickEvent
							do: [ :anEvent |
								self
									onPaneElement: aPaneElement
									resizerDoubleClickEvent: anEvent ] ];
					whenResizedDo: [ :anEvent |
						self onPaneElement: aPaneElement resizedEvent: anEvent ]) ].
	aPaneElement graph
		beNode;
		model: aPaneModel.
	aPaneElement paneModel: aPaneModel.

	^ aPaneElement
]

"I create the panes for Atelier's Tree Pager.

GT's flow element hard-codes GtTreePagerPaneElement in its pane factory. Atelier needs the same navigation, caching, resizing and layout machinery with CFAtelierTreePagerPaneElement as the pane class. This is the construction seam; panes are not restyled after insertion."
Class {
	#name : 'CFAtelierTreePagerFlowPanesElement',
	#superclass : 'GtTreePagerFlowPanesElement',
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}


{ #category : 'initialization' }
CFAtelierTreePagerFlowPanesElement >> defaultLayout [
	^ BlHorizontalTreeFlowLayout new
		numberOfVisibleColumns: 1;
		firstVisibleColumn: 1;
		horizontalOffset: 0;
		horizontalCellSpacing: 0;
		verticalCellSpacing: GtTreePagerConstants verticalCellSpacing
]


{ #category : 'initialization' }
CFAtelierTreePagerFlowPanesElement >> initialize [
	super initialize.
	self preventMouseEvents
]

{ #category : 'private - updating' }
CFAtelierTreePagerFlowPanesElement >> newNodeElementForPaneModel: aPaneModel [
	| aPaneElement |
	aPaneElement := CFAtelierTreePagerPaneElement new.
	aPaneElement
		contentElementDo: [ :aContentElement |
			aContentElement navigationContext: (GtTreePagerPaneNavigationContext new
				pagerElement: self;
				paneElement: aPaneElement) ].
	aPaneElement graph
		beNode;
		model: aPaneModel.
	aPaneElement paneModel: aPaneModel.

	^ aPaneElement
]

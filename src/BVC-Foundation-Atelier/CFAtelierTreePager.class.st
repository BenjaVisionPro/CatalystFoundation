"I am Atelier's Tree Pager element.

I use GT's Tree Pager model and navigation implementation, replacing only the pane-flow factory with Atelier's pane class. This makes Atelier presentation policy structural: every pane is created correctly, including panes added after the root inspector is installed."
Class {
	#name : 'CFAtelierTreePager',
	#superclass : 'GtTreePager',
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'initialization' }
CFAtelierTreePager >> initialize [
	super initialize.

	scrollbarElement removeFromParent.
	panesElement removeFromParent.

	panesElement := CFAtelierTreePagerFlowPanesElement new matchParent.
	scrollbarElement := GtTreePagerScrollbarElement new
		panesElement: panesElement;
		margin: BlInsets empty;
		visibility: BlVisibility gone.

	self
		background: Color transparent;
		padding: BlInsets empty;
		preventMouseEvents;
		addChild: scrollbarElement;
		addChild: panesElement
]

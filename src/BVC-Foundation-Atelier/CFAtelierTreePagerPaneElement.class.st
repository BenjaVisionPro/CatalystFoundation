"I am the Tree Pager pane used by Atelier's overlay inspector.

I keep GT Tree Pager navigation semantics while removing inspector-browser chrome that does not belong in an Atelier workspace. The policy lives on the pane class itself so every pane, including panes created later by relation navigation, is born with the same presentation."
Class {
	#name : 'CFAtelierTreePagerPaneElement',
	#superclass : 'GtTreePagerPaneElement',
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'initialization' }
CFAtelierTreePagerPaneElement >> initialize [
	super initialize.
	self
		background: Color transparent;
		padding: BlInsets empty;
		preventMouseEvents.
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
		preventMouseEvents.
	self hideToolbarElements
]

{ #category : 'api - updating' }
CFAtelierTreePagerPaneElement >> showMaximizeButton [
	self hideMaximizeButton
]

{ #category : 'api - updating' }
CFAtelierTreePagerPaneElement >> showToolbarElements [
	self hideToolbarElements
]

{ #category : 'api - updating' }
CFAtelierTreePagerPaneElement >> showTopRightElement [
	self hideTopRightElement
]

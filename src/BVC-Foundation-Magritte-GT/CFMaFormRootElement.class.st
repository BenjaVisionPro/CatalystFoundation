Class {
	#name : 'CFMaFormRootElement',
	#superclass : 'BrFrame',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'conversion' }
CFMaFormRootElement >> asScrollableElement [
	^ CFSmoothScrollableElement new
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		addChild: self;
		yourself
]

{ #category : 'configuration' }
CFMaFormRootElement >> beEmbedded [
	self
		background: Color transparent;
		hMatchParent;
		vFitContent
]

{ #category : 'initialization' }
CFMaFormRootElement >> initialize [
	"CFMaFormRootElement is the Phlow-facing async form host returned by CFMaViewModel.
	It must provide a full-area container for the generated Foundation form."
	super initialize.

	self
		background: (Color black alpha: 0.10);
		margin: BlInsets empty;
		padding: BlInsets empty;
		focusability: BlFocusability after;
		hMatchParent;
		vFitContent;
		when: BlClickEvent
		do: [ :anEvent |
			"Descendants own focus. I only provide focus when a click leaves
			 this form without a focused descendant."
			self hasFocus ifFalse: [ self requestFocus ] ]
]

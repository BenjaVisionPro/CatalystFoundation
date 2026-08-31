Class {
	#name : #CFMaButtonWithLabelTooltipAptitude,
	#superclass : #BrGlamorousButtonWithLabelTooltipAptitude2,
	#category : #'BVC-Foundation-Magritte-GT-Tooltip'
}

{ #category : #initialization }
CFMaButtonWithLabelTooltipAptitude >> initialize [
	super initialize.

	self menuContainerDo: [ :aContainer |
		aContainer
			beInSeparateCompositionLayer;
			aptitude: CFMaTooltipContainerAptitude new;
			effect: BlNullEffect new ]
]

{ #category : #'api - menu' }
CFMaButtonWithLabelTooltipAptitude >> text: aLabelString shortcut: aShortcutString [
	| aText aTextElement |
	aText := aLabelString asRopedText
		foreground: self theme tooltip foreground;
		fontSize: self theme tooltip fontSize;
		yourself.

	aTextElement := CFMaTooltipTextElement new
		text: aText;
		hFitContent;
		vFitContent;
		constraintsDo: [ :c | c maxWidth: 250 ];
		padding: (BlInsets top: 4 left: 8 bottom: 4 right: 8);
		preventMouseEvents;
		addAptitude: CFMaTooltipSurfaceAptitude new;
		yourself.

	aTextElement addAptitude: (BrLazyStyleCommonAptitude new
		default: [ :aStyle |
			aStyle geometry: (BlRoundedRectangleGeometry
				cornerRadius: aTextElement theme tooltip cornerRadius) ]).

	self
		handle: [ BlElement new
			size: BrMenuConstants handleExtent * 2.0;
			geometry: BlCircleGeometry new;
			background: Color transparent;
			addAptitude: CFMaTooltipSurfaceAptitude new ]
		content: [
			CFMaTooltipShadowElement new
				addChild: aTextElement;
				yourself ]
]

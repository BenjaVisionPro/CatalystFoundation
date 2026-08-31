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
	| aText aSurfaceElement |
	aText := aLabelString asRopedText
		foreground: self theme tooltip foreground;
		fontSize: self theme tooltip fontSize;
		yourself.

	aSurfaceElement := CFMaTooltipSurfaceElement new
		text: aText;
		yourself.

	self
		handle: [ BlElement new
			beInSeparateCompositionLayer;
			size: BrMenuConstants handleExtent * 2.0;
			geometry: BlCircleGeometry new;
			background: Color transparent;
			addAptitude: CFMaTooltipSurfaceAptitude new ]
		content: [
			BlElement new
				layout: BlFrameLayout new;
				constraintsDo: [ :c |
					c horizontal fitContent.
					c vertical fitContent ];
				geometry: (BlRoundedRectangleGeometry
					cornerRadius: self theme tooltip cornerRadius);
				background: Color transparent;
				border: BlBorder empty;
				addAptitude: CFMaTooltipShadowAptitude new;
				addChild: aSurfaceElement;
				yourself ]
]

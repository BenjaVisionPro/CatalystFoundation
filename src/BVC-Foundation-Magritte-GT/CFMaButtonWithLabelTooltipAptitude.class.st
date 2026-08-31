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
			padding: BlInsets empty;
			beInSeparateCompositionLayer;
			aptitude: CFMaTooltipContainerAptitude new;
			effect: BlNullEffect new ]
]

{ #category : #'api - menu' }
CFMaButtonWithLabelTooltipAptitude >> text: aLabelString shortcut: aShortcutString [
	| aText anEditor aSurface aShadowHost |
	aText := aLabelString asRopedText
		foreground: self theme tooltip foreground;
		fontSize: self theme tooltip fontSize;
		yourself.

	anEditor := BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithoutSelection;
		hFitContentLimited;
		vFitContent;
		constraintsDo: [ :c | c maxWidth: 226 ];
		padding: BlInsets empty;
		background: Color transparent;
		border: BlBorder empty;
		focusability: BlFocusability none;
		preventMouseEvents;
		text: aText;
		yourself.

	aSurface := BlElement new
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ];
		padding: (BlInsets top: 8 left: 12 bottom: 8 right: 12);
		geometry: (BlRoundedRectangleGeometry cornerRadius: self theme tooltip cornerRadius);
		beInSeparateCompositionLayer;
		addAptitude: CFGlassSurfaceAptitude new;
		addAptitude: (BrLazyStyleCommonAptitude new
			default: [ :aStyle |
				aStyle border: (BlBorder
					paint: (aSurface theme tooltip borderColor
						blocResolveColorForTheme: aSurface theme)
					width: 1) ]);
		addChild: anEditor;
		yourself.

	aShadowHost := BlElement new
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ];
		geometry: (BlRoundedRectangleGeometry cornerRadius: self theme tooltip cornerRadius);
		background: Color transparent;
		border: BlBorder empty;
		addAptitude: (BrShadowAptitude new
			color: (self theme tooltip shadowColor blocResolveColorForTheme: self theme);
			width: self theme tooltip shadowWidth;
			offset: self theme tooltip shadowOffset;
			yourself);
		addChild: aSurface;
		yourself.

	self
		handle: [ BlElement new
			size: BrMenuConstants handleExtent * 2.0;
			geometry: BlCircleGeometry new;
			background: Color transparent;
			border: BlBorder empty;
			yourself ]
		content: [ aShadowHost ]
]

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
			padding: (BlInsets top: 8 left: 12 bottom: 8 right: 12);
			constraintsDo: [ :c | c maxWidth: 250 ];
			geometry: (BrAnchoredGeometry
				cornerRadius: self theme tooltip cornerRadius
				element: aContainer);
			addAptitude: CFGlassSurfaceAptitude new;
			addAptitude: (BrLazyStyleCommonAptitude new
				default: [ :aStyle |
					aStyle border: (BlBorder
						paint: (aContainer theme tooltip borderColor
							blocResolveColorForTheme: aContainer theme)
						width: 1) ]) ]
]

{ #category : #'api - menu' }
CFMaButtonWithLabelTooltipAptitude >> text: aLabelString shortcut: aShortcutString [
	| aText anEditor |
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

	self
		handle: [ BlElement new
			size: BrMenuConstants handleExtent * 2.0;
			geometry: BlCircleGeometry new;
			background: Color transparent;
			border: BlBorder empty;
			yourself ]
		content: [ anEditor ]
]

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
	| aLabel aLabelAptitude |
	aLabelAptitude := BrGlamorousLabelAptitude new
		weight: 400;
		yourself.
	aLabelAptitude editorMeasurement.
	aLabelAptitude add: (BrLazyStyleCommonAptitude new
		@ aLabelAptitude label;
		default: [ :aStyle |
			aStyle
				foreground: aLabelAptitude theme tooltip foreground;
				fontSize: aLabelAptitude theme tooltip fontSize ]).

	aLabel := BrLabel new
		aptitude: aLabelAptitude;
		text: aLabelString asRopedText;
		hFitContentLimited;
		vFitContent;
		constraintsDo: [ :c | c maxWidth: 250 ];
		padding: (BlInsets top: 4 left: 8 bottom: 4 right: 8);
		preventMouseEvents;
		addAptitude: CFMaTooltipSurfaceAptitude new;
		yourself.

	aLabel addAptitude: (BrLazyStyleCommonAptitude new
		default: [ :aStyle |
			aStyle
				geometry: (BlRoundedRectangleGeometry cornerRadius: aLabel theme tooltip cornerRadius) ]).

	self
		handle: [ BlElement new
			size: BrMenuConstants handleExtent * 2.0;
			geometry: BlCircleGeometry new;
			background: Color transparent;
			addAptitude: CFMaTooltipSurfaceAptitude new ]
		content: [
			CFMaTooltipShadowElement new
				addChild: aLabel;
				yourself ]
]

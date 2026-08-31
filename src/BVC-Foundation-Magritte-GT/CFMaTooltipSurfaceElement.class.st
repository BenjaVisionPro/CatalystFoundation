Class {
	#name : #CFMaTooltipSurfaceElement,
	#superclass : #BlElement,
	#instVars : [
		'editor'
	],
	#category : #'BVC-Foundation-Magritte-GT-Tooltip'
}

{ #category : #initialization }
CFMaTooltipSurfaceElement >> initialize [
	super initialize.

	self
		beInSeparateCompositionLayer;
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent.
			c maxWidth: 250 ];
		padding: (BlInsets top: 8 left: 12 bottom: 8 right: 12);
		preventMouseEvents;
		addAptitude: CFMaTooltipSurfaceAptitude new.

	self addAptitude: (BrLazyStyleCommonAptitude new
		default: [ :aStyle |
			aStyle geometry: (BlRoundedRectangleGeometry
				cornerRadius: self theme tooltip cornerRadius) ]).

	editor := BrEditor new
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
		yourself.

	self addChild: editor
]

{ #category : #accessing }
CFMaTooltipSurfaceElement >> text: aBlText [
	editor text: aBlText
]

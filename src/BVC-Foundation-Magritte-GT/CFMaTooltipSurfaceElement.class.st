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
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent.
			c maxWidth: 250 ];
		padding: (BlInsets top: 4 left: 8 bottom: 4 right: 8);
		preventMouseEvents;
		addAptitude: CFMaTooltipSurfaceAptitude new.

	self addAptitude: (BrLazyStyleCommonAptitude new
		default: [ :aStyle |
			aStyle geometry: (BlRoundedRectangleGeometry
				cornerRadius: self theme tooltip cornerRadius) ]).

	editor := BrEditor new
		beReadOnlyWithoutSelection;
		hFitContentLimited;
		vFitContent;
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

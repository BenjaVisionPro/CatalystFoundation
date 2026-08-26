Class {
	#name : 'CFMaDetailColourSwatchElement',
	#superclass : 'BlElement',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'instance creation' }
CFMaDetailColourSwatchElement class >> automaticSize: anExtent [
	| aSwatch left right |
	aSwatch := self new
		size: anExtent;
		layout: BlFrameLayout new;
		geometry: BlCircleGeometry new;
		clipChildren: true;
		yourself.
	left := BlElement new
		size: (anExtent x / 2.0) @ anExtent y;
		background: CFMaDetailColours textSelectionBlue;
		constraintsDo: [ :c |
			c frame horizontal alignLeft.
			c frame vertical alignCenter ];
		yourself.
	right := BlElement new
		size: (anExtent x / 2.0) @ anExtent y;
		background: CFMaDetailColours textSelectionPink;
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignCenter ];
		yourself.
	aSwatch
		addChild: left;
		addChild: right.
	^ aSwatch
]

{ #category : 'instance creation' }
CFMaDetailColourSwatchElement class >> colour: aColour size: anExtent [
	^ self new
		size: anExtent;
		geometry: BlCircleGeometry new;
		background: aColour;
		yourself
]

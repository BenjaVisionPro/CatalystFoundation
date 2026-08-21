Class {
	#name : 'CFMaDetailSliderElement',
	#superclass : 'BlElement',
	#instVars : [
		'minimum',
		'maximum',
		'value',
		'valueChangedBlock',
		'track',
		'fill',
		'thumb',
		'minimumLabel',
		'currentLabel',
		'maximumLabel',
		'displayBlock'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailSliderElement >> initialize [
	super initialize.
	minimum := 0.
	maximum := 1.
	value := 0.
	valueChangedBlock := [ :aValue | ].
	displayBlock := [ :aValue | aValue asString ].
	self
		layout: CFMaDetailSliderLayout new;
		background: Color transparent;
		border: BlBorder empty;
		padding: BlInsets empty;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ].
	track := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 2);
		background: (Color black alpha: 0.14);
		preventMeAndChildrenMouseEvents;
		yourself.
	fill := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 2);
		background: BrGlamorousColors primaryBorderColor;
		preventMeAndChildrenMouseEvents;
		yourself.
	thumb := BlElement new
		geometry: BlEllipseGeometry new;
		background: Color white;
		border: (BlBorder paint: (Color black alpha: 0.16) width: 0.5);
		preventMeAndChildrenMouseEvents;
		yourself.
	minimumLabel := self newValueLabel.
	currentLabel := self newValueLabel.
	maximumLabel := self newValueLabel.
	self
		addChild: track;
		addChild: fill;
		addChild: thumb;
		addChild: minimumLabel;
		addChild: currentLabel;
		addChild: maximumLabel.
	self
		addEventHandlerOn: BlMouseDownEvent do: [ :anEvent |
			anEvent primaryButtonPressed ifTrue: [ self updateFromMouseEvent: anEvent ] ];
		addEventHandlerOn: BlMouseMoveEvent do: [ :anEvent |
			anEvent primaryButtonPressed ifTrue: [ self updateFromMouseEvent: anEvent ] ].
	self updateLabels
]

{ #category : 'private - building' }
CFMaDetailSliderElement >> newValueLabel [
	^ BrLabel new
		fitContent;
		aptitude: BrGlamorousLabelAptitude new glamorousRegularFontAndSize;
		text: '';
		preventMeAndChildrenMouseEvents;
		yourself
]

{ #category : 'accessing' }
CFMaDetailSliderElement >> displayBlock: aBlock [
	displayBlock := aBlock.
	self updateLabels.
	self requestLayout
]

{ #category : 'accessing' }
CFMaDetailSliderElement >> minimum: aNumber maximum: anotherNumber [
	minimum := aNumber.
	maximum := anotherNumber.
	self updateLabels.
	self requestLayout
]

{ #category : 'accessing' }
CFMaDetailSliderElement >> value [
	^ value
]

{ #category : 'accessing' }
CFMaDetailSliderElement >> value: aNumber [
	value := (aNumber max: minimum) min: maximum.
	self updateLabels.
	self requestLayout
]

{ #category : 'accessing' }
CFMaDetailSliderElement >> valueChangedBlock: aBlock [
	valueChangedBlock := aBlock
]

{ #category : 'geometry' }
CFMaDetailSliderElement >> normalizedValue [
	maximum = minimum ifTrue: [ ^ 0.0 ].
	^ ((value - minimum) / (maximum - minimum)) asFloat
]

{ #category : 'private - interaction' }
CFMaDetailSliderElement >> updateFromMouseEvent: anEvent [
	| aWidth aFraction aValue |
	aWidth := self width.
	aWidth <= 0 ifTrue: [ ^ self ].
	aFraction := ((anEvent localPosition x / aWidth) max: 0.0) min: 1.0.
	aValue := minimum + ((maximum - minimum) * aFraction).
	self value: aValue.
	valueChangedBlock cull: aValue
]

{ #category : 'private - updating' }
CFMaDetailSliderElement >> updateLabels [
	minimumLabel text: (displayBlock cull: minimum).
	currentLabel text: (displayBlock cull: value).
	maximumLabel text: (displayBlock cull: maximum)
]

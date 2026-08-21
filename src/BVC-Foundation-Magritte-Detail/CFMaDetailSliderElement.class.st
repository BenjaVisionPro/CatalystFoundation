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
		'minimumTick',
		'middleTick',
		'maximumTick',
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
		geometry: (BlRoundedRectangleGeometry cornerRadius: CFMaDetailSliderMetrics thumbCornerRadius);
		background: Color white;
		border: (BlBorder paint: (Color black alpha: 0.16) width: 0.5);
		preventMeAndChildrenMouseEvents;
		yourself.
	minimumTick := self newScaleTick.
	middleTick := self newScaleTick.
	maximumTick := self newScaleTick.
	minimumLabel := self newValueLabel.
	currentLabel := self newValueLabel.
	maximumLabel := self newValueLabel.
	self
		addChild: track;
		addChild: fill;
		addChild: thumb;
		addChild: minimumTick;
		addChild: middleTick;
		addChild: maximumTick;
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
CFMaDetailSliderElement >> newScaleTick [
	^ BlElement new
		geometry: BlCircleGeometry new;
		background: (Color black alpha: 0.22);
		preventMeAndChildrenMouseEvents;
		yourself
]

{ #category : 'private - building' }
CFMaDetailSliderElement >> newValueLabel [
	^ BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFont;
			yourself);
		text: (self valueLabelTextFor: '');
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
	| anAxisInset anAxisWidth aFraction aValue |
	anAxisInset := CFMaDetailSliderMetrics axisInset.
	anAxisWidth := self width - (anAxisInset * 2.0).
	anAxisWidth <= 0 ifTrue: [ ^ self ].
	aFraction := (((anEvent localPosition x - anAxisInset) / anAxisWidth) max: 0.0) min: 1.0.
	aValue := minimum + ((maximum - minimum) * aFraction).
	self value: aValue.
	valueChangedBlock cull: aValue
]

{ #category : 'private - updating' }
CFMaDetailSliderElement >> updateLabels [
	minimumLabel text: (self valueLabelTextFor: (displayBlock cull: minimum)).
	currentLabel
		text: (self valueLabelTextFor: (displayBlock cull: value rounded));
		visibility: ((self normalizedValue = 0.0 or: [ self normalizedValue = 1.0 ])
			ifTrue: [ BlVisibility hidden ]
			ifFalse: [ BlVisibility visible ]).
	maximumLabel text: (self valueLabelTextFor: (displayBlock cull: maximum))
]

{ #category : 'private - styling' }
CFMaDetailSliderElement >> valueLabelTextFor: aString [
	^ aString asRopedText
		foreground: (Color black alpha: 0.8);
		fontSize: 11;
		yourself
]

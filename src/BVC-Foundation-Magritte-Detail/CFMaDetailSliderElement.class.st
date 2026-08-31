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
		padding: (BlInsets right: CFMaDetailScalarFieldMetrics trailingControlInset);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ].
	track := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 2);
		background: BrGlamorousColors lightBorderColor;
		preventMeAndChildrenMouseEvents;
		yourself.
	fill := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 2);
		background: BrGlamorousColors primaryBorderColor;
		preventMeAndChildrenMouseEvents;
		yourself.
	thumb := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: CFMaDetailSliderMetrics thumbCornerRadius);
		background: BrGlamorousColors defaultButtonBackgroundColor;
		border: (BlBorder paint: BrGlamorousColors defaultButtonBorderColor width: 0.5);
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
		addChild: minimumTick;
		addChild: middleTick;
		addChild: maximumTick;
		addChild: thumb;
		addChild: minimumLabel;
		addChild: currentLabel;
		addChild: maximumLabel.
	self
		addEventHandlerOn: BlMouseDownEvent do: [ :anEvent |
			anEvent primaryButtonPressed ifTrue: [
				self updateFromLocalPosition: anEvent localPosition.
				self requestFocus ] ];
		addEventHandlerOn: BlMouseUpEvent do: [ :anEvent |
			anEvent consumed: true ];
		addEventHandlerOn: BlClickEvent do: [ :anEvent |
			anEvent consumed: true ];
		addEventHandlerOn: BlDragStartEvent do: [ :anEvent |
			anEvent consumed: true ];
		addEventHandlerOn: BlDragEvent do: [ :anEvent |
			anEvent consumed: true.
			self updateFromLocalPosition: anEvent localPosition ].
	self updateLabels
]



{ #category : 'layout' }
CFMaDetailSliderElement >> supportsBaseline [
	^ true
]

{ #category : 'layout' }
CFMaDetailSliderElement >> baselineOffset [
	^ CFMaDetailSliderMetrics trackY + CFMaDetailSliderMetrics trackHeight + 1
]

{ #category : 'private - building' }
CFMaDetailSliderElement >> newScaleTick [
	^ BlElement new
		geometry: BlCircleGeometry new;
		background: BrGlamorousColors lightBorderColor;
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
CFMaDetailSliderElement >> updateFromLocalPosition: aPoint [
	| padding anAxisInset anAxisStart anAxisEnd anAxisWidth aFraction aValue |
	self states isDisabled ifTrue: [ ^ self ].
	padding := self padding.
	anAxisInset := CFMaDetailSliderMetrics axisInset.
	anAxisStart := padding left + anAxisInset.
	anAxisEnd := self width - padding right - anAxisInset.
	anAxisWidth := anAxisEnd - anAxisStart.
	anAxisWidth <= 0 ifTrue: [ ^ self ].
	aFraction := (((aPoint x - anAxisStart) / anAxisWidth) max: 0.0) min: 1.0.
	aValue := minimum + ((maximum - minimum) * aFraction).
	self value: aValue.
	valueChangedBlock cull: aValue
]

{ #category : 'private - updating' }
CFMaDetailSliderElement >> updateLabels [
	minimumLabel text: (self valueLabelTextFor: (displayBlock cull: minimum)).
	currentLabel
		text: (self valueLabelTextFor: (displayBlock cull: value rounded));
		visibility: ((value = minimum or: [ value = maximum ])
			ifTrue: [ BlVisibility hidden ]
			ifFalse: [ BlVisibility visible ]).
	maximumLabel text: (self valueLabelTextFor: (displayBlock cull: maximum))
]

{ #category : 'private - styling' }
CFMaDetailSliderElement >> valueLabelTextFor: aString [
	^ aString asRopedText
		foreground: self theme typography secondaryForeground;
		fontSize: self theme typography supportingFontSize;
		yourself
]

{ #category : 'lifecycle' }
CFMaDetailSliderElement >> onThemeChanged [
	super onThemeChanged.
	track ifNotNil: [
		self updateThemeAppearance.
		minimumLabel ifNotNil: [ self updateLabels ] ]
]

{ #category : 'private - styling' }
CFMaDetailSliderElement >> updateThemeAppearance [
	| aTheme |
	aTheme := self theme.
	track background: (aTheme controls sliderTrackTint blocResolveColorForTheme: aTheme).
	fill background: (aTheme controls sliderActiveTrackTint blocResolveColorForTheme: aTheme).
	thumb
		background: (aTheme controls sliderThumbBackground blocResolveColorForTheme: aTheme);
		border: (BlBorder
			paint: (aTheme controls sliderThumbBorderTint blocResolveColorForTheme: aTheme)
			width: 0.5).
	{ minimumTick. middleTick. maximumTick } do: [ :aTick |
		aTick background: (aTheme controls sliderTickTint blocResolveColorForTheme: aTheme) ]
]


{ #category : 'private - layout' }
CFMaDetailSliderElement >> sliderTrack [
	^ track
]

{ #category : 'private - layout' }
CFMaDetailSliderElement >> sliderFill [
	^ fill
]

{ #category : 'private - layout' }
CFMaDetailSliderElement >> sliderThumb [
	^ thumb
]

{ #category : 'private - layout' }
CFMaDetailSliderElement >> minimumTick [
	^ minimumTick
]

{ #category : 'private - layout' }
CFMaDetailSliderElement >> middleTick [
	^ middleTick
]

{ #category : 'private - layout' }
CFMaDetailSliderElement >> maximumTick [
	^ maximumTick
]

{ #category : 'private - layout' }
CFMaDetailSliderElement >> minimumLabel [
	^ minimumLabel
]

{ #category : 'private - layout' }
CFMaDetailSliderElement >> currentLabel [
	^ currentLabel
]

{ #category : 'private - layout' }
CFMaDetailSliderElement >> maximumLabel [
	^ maximumLabel
]

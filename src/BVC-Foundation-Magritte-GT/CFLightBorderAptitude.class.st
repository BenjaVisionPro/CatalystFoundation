Class {
	#name : 'CFLightBorderAptitude',
	#superclass : 'BrAptitude',
	#instVars : [
		'width',
		'lightOffsetFactor',
		'lightDirection',
		'highlightColor',
		'shadowColor',
		'insetShadowColor',
		'insetShadowDepth',
		'borderColor',
		'style'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultBorderColor [
	^ Color white alpha: 0.12
]

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultHighlightColor [
	^ Color white alpha: 0.55
]

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultInsetShadowColor [
	^ Color black alpha: 0.2
]

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultInsetShadowDepth [
	^ 4
]

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultLightDirection [
	^ (-1 @ -1) asBlocVector normalized
]

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultLightOffsetFactor [
	^ 0.75
]

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultShadowColor [
	^ Color black alpha: 0.28
]

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultWidth [
	^ 1
]

{ #category : 'configuration' }
CFLightBorderAptitude >> beFlat [
	style := #flat.
	^ self
]

{ #category : 'configuration' }
CFLightBorderAptitude >> beInset [
	style := #inset.
	^ self
]

{ #category : 'configuration' }
CFLightBorderAptitude >> beOutset [
	self beRaised
]

{ #category : 'configuration' }
CFLightBorderAptitude >> bePressed [
	style := #pressed.
	^ self
]

{ #category : 'configuration' }
CFLightBorderAptitude >> beRaised [
	style := #raised.
	^ self
]

{ #category : 'accessing' }
CFLightBorderAptitude >> border [
	"BlBorder is the native flat-border representation. Raised and inset
	styles are multi-pass surface effects; their base stroke must be painted
	between their shadow and highlight to preserve the original rendering."
	style = #flat ifTrue: [ ^ BlBorder paint: borderColor width: width ].
	^ BlBorder empty
]

{ #category : 'accessing' }
CFLightBorderAptitude >> borderColor [
	^ borderColor
]

{ #category : 'accessing' }
CFLightBorderAptitude >> borderColor: aColor [
	borderColor := aColor
]

{ #category : 'private - effects' }
CFLightBorderAptitude >> effectComposedWith: anEffect [
	self hasLighting ifFalse: [ ^ anEffect ].
	^ self lightingEffect underlyingEffect: anEffect
]

{ #category : 'testing' }
CFLightBorderAptitude >> hasLighting [
	^ style ~= #flat
]

{ #category : 'accessing' }
CFLightBorderAptitude >> highlightColor [
	^ highlightColor
]

{ #category : 'accessing' }
CFLightBorderAptitude >> highlightColor: aColor [
	highlightColor := aColor
]

{ #category : 'initialization' }
CFLightBorderAptitude >> initialize [
	super initialize.
	width := self class defaultWidth.
	lightOffsetFactor := self class defaultLightOffsetFactor.
	lightDirection := self class defaultLightDirection.
	highlightColor := self class defaultHighlightColor.
	shadowColor := self class defaultShadowColor.
	insetShadowColor := self class defaultInsetShadowColor.
	insetShadowDepth := self class defaultInsetShadowDepth.
	borderColor := self class defaultBorderColor.
	style := #raised.

	"The flat style is a native BlBorder. The lit styles are a multi-pass
	effect, so they never participate in the widget's child layout."
	self addChangeProperty: #(widget outskirts) with: [ BlOutskirts centered ].
	self addChangeProperty: #(widget border) with: [ self border ].
	self
		addChangeProperty: #(widget effect)
		with: [ :anEffect | self effectComposedWith: anEffect ]
]

{ #category : 'accessing' }
CFLightBorderAptitude >> insetShadowColor [
	^ insetShadowColor
]

{ #category : 'accessing' }
CFLightBorderAptitude >> insetShadowColor: aColor [
	insetShadowColor := aColor
]

{ #category : 'accessing' }
CFLightBorderAptitude >> insetShadowDepth [
	^ insetShadowDepth
]

{ #category : 'accessing' }
CFLightBorderAptitude >> insetShadowDepth: aNumber [
	insetShadowDepth := aNumber max: 0
]

{ #category : 'accessing' }
CFLightBorderAptitude >> lightDirection [
	^ lightDirection
]

{ #category : 'accessing' }
CFLightBorderAptitude >> lightDirection: aPointOrVector [
	lightDirection := self normalizedVectorFrom: aPointOrVector
]

{ #category : 'accessing' }
CFLightBorderAptitude >> lightDirectionDegrees: aNumber [
	lightDirection := self normalizedVectorFromDegrees: aNumber
]

{ #category : 'accessing' }
CFLightBorderAptitude >> lightOffsetFactor [
	^ lightOffsetFactor
]

{ #category : 'accessing' }
CFLightBorderAptitude >> lightOffsetFactor: aNumber [
	lightOffsetFactor := aNumber max: 0
]

{ #category : 'private - effects' }
CFLightBorderAptitude >> lightingEffect [
	^ CFLightBorderEffect new
		width: width;
		lightOffsetFactor: lightOffsetFactor;
		lightDirection: lightDirection;
		highlightColor: highlightColor;
		borderColor: borderColor;
		shadowColor: shadowColor;
		insetShadowColor: insetShadowColor;
		insetShadowDepth: insetShadowDepth;
		style: style;
		yourself
]

{ #category : 'private - geometry' }
CFLightBorderAptitude >> normalizedVectorFrom: aPointOrVector [
	| vector |
	aPointOrVector isNumber ifTrue: [ ^ self normalizedVectorFromDegrees: aPointOrVector ].
	vector := aPointOrVector asBlocVector.
	vector length isZero ifTrue: [ ^ self class defaultLightDirection ].
	^ vector normalized
]

{ #category : 'private - geometry' }
CFLightBorderAptitude >> normalizedVectorFromDegrees: aNumber [
	| radians |
	radians := aNumber * Float pi / 180.0.
	^ (radians cos @ radians sin) asBlocVector normalized
]

{ #category : 'accessing' }
CFLightBorderAptitude >> shadowColor [
	^ shadowColor
]

{ #category : 'accessing' }
CFLightBorderAptitude >> shadowColor: aColor [
	shadowColor := aColor
]

{ #category : 'accessing' }
CFLightBorderAptitude >> style [
	^ style
]

{ #category : 'accessing' }
CFLightBorderAptitude >> width [
	^ width
]

{ #category : 'accessing' }
CFLightBorderAptitude >> width: aNumber [
	width := aNumber max: 0
]

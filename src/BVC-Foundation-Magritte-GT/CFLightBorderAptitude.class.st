Class {
	#name : 'CFLightBorderAptitude',
	#superclass : 'BrAptitude',
	#instVars : [
		'effectWidth',
		'depth',
		'lightOffsetFactor',
		'lightDirection',
		'highlightColor',
		'shadowColor',
		'bodyRelief',
		'borderRelief'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultDepth [
	^ 4
]

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultEffectWidth [
	"Width of each alpha-blended bevel layer. It is independent from the
	element's BlBorder width."
	^ 1
]

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultHighlightColor [
	^ Color white alpha: 0.55
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

{ #category : 'configuration' }
CFLightBorderAptitude >> beFlat [
	bodyRelief := #flat.
	borderRelief := #flat.
	^ self
]

{ #category : 'configuration' }
CFLightBorderAptitude >> beInset [
	^ self beLowered
]

{ #category : 'configuration' }
CFLightBorderAptitude >> beLowered [
	bodyRelief := #lowered.
	borderRelief := #lowered.
	^ self
]

{ #category : 'configuration' }
CFLightBorderAptitude >> beOutset [
	^ self beRaised
]

{ #category : 'configuration' }
CFLightBorderAptitude >> bePressed [
	^ self beLowered
]

{ #category : 'configuration' }
CFLightBorderAptitude >> beRaised [
	bodyRelief := #raised.
	borderRelief := #raised.
	^ self
]

{ #category : 'accessing' }
CFLightBorderAptitude >> bodyRelief [
	^ bodyRelief
]

{ #category : 'accessing' }
CFLightBorderAptitude >> borderRelief [
	^ borderRelief
]

{ #category : 'accessing' }
CFLightBorderAptitude >> depth [
	^ depth ifNil: [ self class defaultDepth ]
]

{ #category : 'accessing' }
CFLightBorderAptitude >> depth: aNumber [
	depth := aNumber max: 0
]

{ #category : 'accessing' }
CFLightBorderAptitude >> effectWidth [
	^ effectWidth ifNil: [ self class defaultEffectWidth ]
]

{ #category : 'accessing' }
CFLightBorderAptitude >> effectWidth: aNumber [
	effectWidth := aNumber max: 0
]

{ #category : 'private - effects' }
CFLightBorderAptitude >> effectComposedWith: anEffect [
	self hasLighting ifFalse: [ ^ anEffect ].
	^ self lightingEffect underlyingEffect: anEffect
]

{ #category : 'configuration - body' }
CFLightBorderAptitude >> flattenBody [
	bodyRelief := #flat.
	^ self
]

{ #category : 'configuration - border' }
CFLightBorderAptitude >> flattenBorder [
	borderRelief := #flat.
	^ self
]

{ #category : 'testing' }
CFLightBorderAptitude >> hasLighting [
	^ bodyRelief ~= #flat or: [ borderRelief ~= #flat ]
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
	effectWidth := self class defaultEffectWidth.
	depth := self class defaultDepth.
	lightOffsetFactor := self class defaultLightOffsetFactor.
	lightDirection := self class defaultLightDirection.
	highlightColor := self class defaultHighlightColor.
	shadowColor := self class defaultShadowColor.
	self beRaised.

	self
		addChangeProperty: #(widget effect)
		with: [ :anEffect | self effectComposedWith: anEffect ]
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
		effectWidth: self effectWidth;
		depth: self depth;
		lightOffsetFactor: lightOffsetFactor;
		lightDirection: lightDirection;
		highlightColor: highlightColor;
		shadowColor: shadowColor;
		bodyRelief: bodyRelief;
		borderRelief: borderRelief;
		yourself
]

{ #category : 'configuration - body' }
CFLightBorderAptitude >> lowerBody [
	bodyRelief := #lowered.
	^ self
]

{ #category : 'configuration - border' }
CFLightBorderAptitude >> lowerBorder [
	borderRelief := #lowered.
	^ self
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

{ #category : 'configuration - body' }
CFLightBorderAptitude >> raiseBody [
	bodyRelief := #raised.
	^ self
]

{ #category : 'configuration - border' }
CFLightBorderAptitude >> raiseBorder [
	borderRelief := #raised.
	^ self
]

{ #category : 'accessing' }
CFLightBorderAptitude >> shadowColor [
	^ shadowColor
]

{ #category : 'accessing' }
CFLightBorderAptitude >> shadowColor: aColor [
	shadowColor := aColor
]

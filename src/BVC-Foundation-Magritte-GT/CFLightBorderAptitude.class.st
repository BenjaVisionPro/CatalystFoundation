Class {
	#name : 'CFLightBorderAptitude',
	#superclass : 'BrAptitude',
	#instVars : [
		'effectWidth',
		'opacity',
		'lightDirection',
		'highlightColor',
		'shadowColor',
		'bodyActive',
		'bodyRaised',
		'bodyInside',
		'borderActive',
		'borderRaised',
		'borderInside'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultEffectWidth [
	^ 2
]

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultHighlightColor [
	^ Color white alpha: 0.75
]

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultIntensity [
	^ 1.0
]

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultLightDirection [
	^ CFInterfaceLighting lightDirection
]

{ #category : 'defaults' }
CFLightBorderAptitude class >> defaultShadowColor [
	^ Color black alpha: 0.45
]

{ #category : 'configuration' }
CFLightBorderAptitude >> beFlat [
	bodyActive := false.
	borderActive := false.
	^ self
]

{ #category : 'configuration' }
CFLightBorderAptitude >> beLowered [
	self lowerBodyInside.
	self lowerBorderOutside.
	^ self
]

{ #category : 'configuration' }
CFLightBorderAptitude >> beRaised [
	self raiseBodyInside.
	self raiseBorderOutside.
	^ self
]

{ #category : 'private - effects' }
CFLightBorderAptitude >> effectComposedWith: anEffect [
	self hasLighting ifFalse: [ ^ anEffect ].
	^ self lightingEffect
		underlyingEffect: anEffect;
		yourself
]

{ #category : 'accessing' }
CFLightBorderAptitude >> effectWidth [
	^ effectWidth ifNil: [ self class defaultEffectWidth ]
]

{ #category : 'accessing' }
CFLightBorderAptitude >> effectWidth: aNumber [
	effectWidth := aNumber max: 0
]

{ #category : 'testing' }
CFLightBorderAptitude >> hasLighting [
	^ bodyActive or: [ borderActive ]
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
	opacity := self class defaultIntensity.
	lightDirection := self class defaultLightDirection.
	highlightColor := self class defaultHighlightColor.
	shadowColor := self class defaultShadowColor.
	bodyActive := false.
	borderActive := false.
	self beRaised.

	self
		addChangeProperty: #(widget effect)
		with: [ :anEffect | self effectComposedWith: anEffect ]
]

{ #category : 'accessing' }
CFLightBorderAptitude >> intensity [
	^ opacity ifNil: [ self class defaultIntensity ]
]

{ #category : 'accessing' }
CFLightBorderAptitude >> intensity: aNumber [
	opacity := (aNumber max: 0.0) min: 1.0
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

{ #category : 'private - effects' }
CFLightBorderAptitude >> lightingEffect [
	^ CFLightBorderEffect new
		effectWidth: self effectWidth;
		intensity: self intensity;
		lightDirection: lightDirection;
		highlightColor: highlightColor;
		shadowColor: shadowColor;
		bodyActive: bodyActive raised: bodyRaised inside: bodyInside;
		borderActive: borderActive raised: borderRaised inside: borderInside;
		yourself
]

{ #category : 'configuration - body' }
CFLightBorderAptitude >> lowerBodyInside [
	bodyActive := true.
	bodyRaised := false.
	bodyInside := true.
	^ self
]

{ #category : 'configuration' }
CFLightBorderAptitude >> lowerBodyInsideRaiseBorderOutside [
	self lowerBodyInside.
	self raiseBorderOutside.
	^ self
]

{ #category : 'configuration - body' }
CFLightBorderAptitude >> lowerBodyOutside [
	bodyActive := true.
	bodyRaised := false.
	bodyInside := false.
	^ self
]

{ #category : 'configuration - border' }
CFLightBorderAptitude >> lowerBorderInside [
	borderActive := true.
	borderRaised := false.
	borderInside := true.
	^ self
]

{ #category : 'configuration - border' }
CFLightBorderAptitude >> lowerBorderOutside [
	borderActive := true.
	borderRaised := false.
	borderInside := false.
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
CFLightBorderAptitude >> raiseBodyInside [
	bodyActive := true.
	bodyRaised := true.
	bodyInside := true.
	^ self
]

{ #category : 'configuration' }
CFLightBorderAptitude >> raiseBodyInsideLowerBorderOutside [
	self raiseBodyInside.
	self lowerBorderOutside.
	^ self
]

{ #category : 'configuration - body' }
CFLightBorderAptitude >> raiseBodyOutside [
	bodyActive := true.
	bodyRaised := true.
	bodyInside := false.
	^ self
]

{ #category : 'configuration - border' }
CFLightBorderAptitude >> raiseBorderInside [
	borderActive := true.
	borderRaised := true.
	borderInside := true.
	^ self
]

{ #category : 'configuration - border' }
CFLightBorderAptitude >> raiseBorderOutside [
	borderActive := true.
	borderRaised := true.
	borderInside := false.
	^ self
]

{ #category : 'configuration - body' }
CFLightBorderAptitude >> removeBodyTreatment [
	bodyActive := false.
	^ self
]

{ #category : 'configuration - border' }
CFLightBorderAptitude >> removeBorderTreatment [
	borderActive := false.
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

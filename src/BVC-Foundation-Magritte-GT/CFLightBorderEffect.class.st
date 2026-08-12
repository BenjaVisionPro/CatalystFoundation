Class {
	#name : 'CFLightBorderEffect',
	#superclass : 'BlElementEffect',
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
		'borderInside',
		'underlyingEffect'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'defaults' }
CFLightBorderEffect class >> defaultEffectWidth [
	^ 8
]

{ #category : 'defaults' }
CFLightBorderEffect class >> defaultOpacity [
	^ 1.0
]

{ #category : 'drawing' }
CFLightBorderEffect >> applyAfterOnSpartaCanvas: aCanvas for: anElement [
	borderActive ifTrue: [
		borderInside ifTrue: [ self drawBorderTreatmentFor: anElement onSpartaCanvas: aCanvas ] ].
	bodyActive ifTrue: [
		bodyInside ifTrue: [ self drawBodyTreatmentFor: anElement onSpartaCanvas: aCanvas ] ]
]

{ #category : 'drawing' }
CFLightBorderEffect >> applyBeforeOnSpartaCanvas: aCanvas for: anElement [
	borderActive ifTrue: [
		borderInside ifFalse: [ self drawBorderTreatmentFor: anElement onSpartaCanvas: aCanvas ] ].
	bodyActive ifTrue: [
		bodyInside ifFalse: [ self drawBodyTreatmentFor: anElement onSpartaCanvas: aCanvas ] ]
]

{ #category : 'drawing' }
CFLightBorderEffect >> applyEffectOnSpartaCanvas: aCanvas for: anElement around: aBlock [
	underlyingEffect ifNil: [
		^ super
			applyEffectOnSpartaCanvas: aCanvas
			for: anElement
			around: aBlock ].
	self applyBeforeOnSpartaCanvas: aCanvas for: anElement.
	underlyingEffect
		applyEffectOnSpartaCanvas: aCanvas
		for: anElement
		around: aBlock.
	self applyAfterOnSpartaCanvas: aCanvas for: anElement
]

{ #category : 'accessing' }
CFLightBorderEffect >> bodyActive: isActive raised: isRaised inside: isInside [
	bodyActive := isActive.
	bodyRaised := isRaised.
	bodyInside := isInside
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> bodyBoundaryInsetFor: anElement [
	| width |
	width := anElement border width.
	anElement outskirts = BlOutskirts inside ifTrue: [ ^ width ].
	anElement outskirts = BlOutskirts centered ifTrue: [ ^ width / 2.0 ].
	anElement outskirts = BlOutskirts outside ifTrue: [ ^ 0 ].
	^ 0
]

{ #category : 'accessing' }
CFLightBorderEffect >> borderActive: isActive raised: isRaised inside: isInside [
	borderActive := isActive.
	borderRaised := isRaised.
	borderInside := isInside
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> borderOuterBoundaryInsetFor: anElement [
	| width |
	width := anElement border width.
	anElement outskirts = BlOutskirts inside ifTrue: [ ^ 0 ].
	anElement outskirts = BlOutskirts centered ifTrue: [ ^ width / -2.0 ].
	anElement outskirts = BlOutskirts outside ifTrue: [ ^ width negated ].
	^ 0
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> boundaryPathFor: anElement onSpartaCanvas: aCanvas insetBy: anInset [
	| path |
	path := anElement geometry pathOnSpartaCanvas: aCanvas of: anElement.
	anInset isZero ifTrue: [ ^ path ].
	(path respondsTo: #insetBy:) ifTrue: [ ^ path insetBy: anInset ].
	^ path
]

{ #category : 'geometry' }
CFLightBorderEffect >> computeBounds: aBlBounds [
	| effectBounds |
	effectBounds := underlyingEffect
		ifNil: [ aBlBounds ]
		ifNotNil: [ underlyingEffect computeBounds: aBlBounds ].
	^ self hasLighting
		ifTrue: [ effectBounds expandBy: self effectWidth + self maximumBorderOutset ]
		ifFalse: [ effectBounds ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBodyTreatmentFor: anElement onSpartaCanvas: aCanvas [
	| boundaryInset treatmentInset path |
	bodyActive ifFalse: [ ^ self ].
	boundaryInset := self bodyBoundaryInsetFor: anElement.
	treatmentInset := bodyInside
		ifTrue: [ boundaryInset + (self effectWidth / 2.0) ]
		ifFalse: [ boundaryInset - (self effectWidth / 2.0) ].
	path := self
		boundaryPathFor: anElement
		onSpartaCanvas: aCanvas
		insetBy: treatmentInset.
	path ifNil: [ ^ self ].
	self
		drawTreatmentPath: path
		raised: bodyRaised
		for: anElement
		onSpartaCanvas: aCanvas
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBorderTreatmentFor: anElement onSpartaCanvas: aCanvas [
	| boundaryInset treatmentInset path |
	borderActive ifFalse: [ ^ self ].
	boundaryInset := self borderOuterBoundaryInsetFor: anElement.
	treatmentInset := borderInside
		ifTrue: [ boundaryInset + (self effectWidth / 2.0) ]
		ifFalse: [ boundaryInset - (self effectWidth / 2.0) ].
	path := self
		boundaryPathFor: anElement
		onSpartaCanvas: aCanvas
		insetBy: treatmentInset.
	path ifNil: [ ^ self ].
	self
		drawTreatmentPath: path
		raised: borderRaised
		for: anElement
		onSpartaCanvas: aCanvas
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawTreatmentPath: aPath raised: isRaised for: anElement onSpartaCanvas: aCanvas [
	aCanvas stroke
		paint: (self gradientPaintFor: anElement raised: isRaised onSpartaCanvas: aCanvas);
		path: aPath;
		width: self effectWidth;
		draw
]


{ #category : 'accessing' }
CFLightBorderEffect >> effectWidth [
	^ effectWidth ifNil: [ self class defaultEffectWidth ]
]

{ #category : 'accessing' }
CFLightBorderEffect >> effectWidth: aNumber [
	effectWidth := aNumber max: 0
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> effectiveColor: aColor [
	^ aColor alpha: aColor alpha * self opacity
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> gradientPaintFor: anElement raised: isRaised onSpartaCanvas: aCanvas [
	| bounds center vector halfLength start finish highlight shadow |
	bounds := anElement boundsInLocal.
	center := bounds center.
	vector := lightDirection asBlocVector normalized asPoint.
	halfLength := ((bounds width squared + bounds height squared) sqrt) / 2.0.
	start := center + (vector * halfLength).
	finish := center - (vector * halfLength).
	highlight := self effectiveColor: highlightColor.
	shadow := self effectiveColor: shadowColor.
	^ aCanvas paint linearGradient
		stops: (isRaised
			ifTrue: [ {
				0 -> highlight.
				0.42 -> (highlight alpha: 0.05 * self opacity).
				0.58 -> (shadow alpha: 0.05 * self opacity).
				1 -> shadow } ]
			ifFalse: [ {
				0 -> shadow.
				0.42 -> (shadow alpha: 0.05 * self opacity).
				0.58 -> (highlight alpha: 0.05 * self opacity).
				1 -> highlight } ]);
		begin: start;
		end: finish;
		yourself
]

{ #category : 'testing' }
CFLightBorderEffect >> hasLighting [
	^ bodyActive or: [ borderActive ]
]

{ #category : 'accessing' }
CFLightBorderEffect >> highlightColor: aColor [
	highlightColor := aColor
]

{ #category : 'initialization' }
CFLightBorderEffect >> initialize [
	super initialize.
	bodyActive := false.
	borderActive := false
]

{ #category : 'accessing' }
CFLightBorderEffect >> lightDirection: aVector [
	lightDirection := aVector
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> maximumBorderOutset [
	^ self effectWidth
]

{ #category : 'accessing' }
CFLightBorderEffect >> opacity [
	^ opacity ifNil: [ self class defaultOpacity ]
]

{ #category : 'accessing' }
CFLightBorderEffect >> opacity: aNumber [
	opacity := (aNumber max: 0.0) min: 1.0
]

{ #category : 'drawing' }
CFLightBorderEffect >> paintOn: aCompositorPainter offset: anOffset for: anElement thenPaint: aBlock [
	aCompositorPainter canvas transform
		by: [ :aTransform | aTransform translateBy: anOffset ]
		during: [ self applyBeforeOnSpartaCanvas: aCompositorPainter canvas for: anElement ].
	underlyingEffect
		ifNil: [ aBlock cull: aCompositorPainter cull: anOffset ]
		ifNotNil: [
			underlyingEffect
				paintOn: aCompositorPainter
				offset: anOffset
				for: anElement
				thenPaint: aBlock ].
	aCompositorPainter canvas transform
		by: [ :aTransform | aTransform translateBy: anOffset ]
		during: [ self applyAfterOnSpartaCanvas: aCompositorPainter canvas for: anElement ]
]

{ #category : 'accessing' }
CFLightBorderEffect >> shadowColor: aColor [
	shadowColor := aColor
]

{ #category : 'accessing' }
CFLightBorderEffect >> underlyingEffect [
	^ underlyingEffect
]

{ #category : 'accessing' }
CFLightBorderEffect >> underlyingEffect: anEffect [
	underlyingEffect := anEffect.
	^ self
]

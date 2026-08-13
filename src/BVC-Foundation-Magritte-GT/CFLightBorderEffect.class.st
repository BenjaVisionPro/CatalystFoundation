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
	"Body treatments are element-facing and must remain visible over the body or native border."
	bodyActive ifTrue: [ self drawBodyTreatmentFor: anElement onSpartaCanvas: aCanvas ].
	borderActive ifTrue: [
		borderInside ifTrue: [ self drawBorderTreatmentFor: anElement onSpartaCanvas: aCanvas ] ]
]

{ #category : 'drawing' }
CFLightBorderEffect >> applyBeforeOnSpartaCanvas: aCanvas for: anElement [
	"An outside-border treatment belongs beyond the native element paint."
	borderActive ifTrue: [
		borderInside ifFalse: [ self drawBorderTreatmentFor: anElement onSpartaCanvas: aCanvas ] ]
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
CFLightBorderEffect >> bodyBoundaryCoordinateFor: anElement [
	"Signed distance from the element geometry path to the inner/native body edge.
	Positive is toward the element interior; negative is toward the exterior."
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
CFLightBorderEffect >> borderOuterBoundaryCoordinateFor: anElement [
	"Signed distance from the element geometry path to the outer/native border edge.
	Positive is toward the element interior; negative is toward the exterior."
	| width |
	width := anElement border width.
	anElement outskirts = BlOutskirts inside ifTrue: [ ^ 0 ].
	anElement outskirts = BlOutskirts centered ifTrue: [ ^ width / -2.0 ].
	anElement outskirts = BlOutskirts outside ifTrue: [ ^ width negated ].
	^ 0
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> geometryPathFor: anElement onSpartaCanvas: aCanvas [
	(anElement geometry respondsTo: #pathOnSpartaCanvas:of:) ifFalse: [ ^ nil ].
	^ anElement geometry pathOnSpartaCanvas: aCanvas of: anElement
]

{ #category : 'geometry' }
CFLightBorderEffect >> computeBounds: aBlBounds [
	| effectBounds |
	effectBounds := underlyingEffect
		ifNil: [ aBlBounds ]
		ifNotNil: [ underlyingEffect computeBounds: aBlBounds ].
	^ self hasLighting
		ifTrue: [ effectBounds expandBy: self effectWidth ]
		ifFalse: [ effectBounds ]
]



{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBodyTreatmentFor: anElement onSpartaCanvas: aCanvas [
	| bodyBoundary borderBoundary width from to |
	bodyActive ifFalse: [ ^ self ].
	bodyBoundary := self bodyBoundaryCoordinateFor: anElement.
	borderBoundary := self borderOuterBoundaryCoordinateFor: anElement.
	width := self effectWidth.

	bodyInside
		ifTrue: [
			from := bodyBoundary.
			to := bodyBoundary + width ]
		ifFalse: [
			from := bodyBoundary - width.
			anElement border width isZero ifFalse: [ from := from max: borderBoundary ].
			to := bodyBoundary ].

	self
		drawTreatmentBandFrom: from
		to: to
		raised: bodyRaised
		for: anElement
		onSpartaCanvas: aCanvas
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBorderTreatmentFor: anElement onSpartaCanvas: aCanvas [
	| outerBoundary bodyBoundary width from to |
	borderActive ifFalse: [ ^ self ].
	anElement border width isZero ifTrue: [ ^ self ].
	outerBoundary := self borderOuterBoundaryCoordinateFor: anElement.
	bodyBoundary := self bodyBoundaryCoordinateFor: anElement.
	width := self effectWidth.

	borderInside
		ifTrue: [
			from := outerBoundary.
			to := (outerBoundary + width) min: bodyBoundary ]
		ifFalse: [
			from := outerBoundary - width.
			to := outerBoundary ].

	self
		drawTreatmentBandFrom: from
		to: to
		raised: borderRaised
		for: anElement
		onSpartaCanvas: aCanvas
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawTreatmentBandFrom: aSignedDistance to: anotherSignedDistance raised: isRaised for: anElement onSpartaCanvas: aCanvas [
	"I rasterize the treatment from the same element path and centered-stroke
	geometry that Bloc uses for native borders. Positive distances are inside the
	element path; negative distances are outside. I never construct an offset
	shape, so rounded corners and arbitrary geometries share Bloc's own stroke
	semantics."
	| low high |
	self effectWidth isZero ifTrue: [ ^ self ].
	low := aSignedDistance min: anotherSignedDistance.
	high := aSignedDistance max: anotherSignedDistance.
	low = high ifTrue: [ ^ self ].

	aCanvas similar: aCanvas extent during: [ :treatmentCanvas |
		| path |
		path := self geometryPathFor: anElement onSpartaCanvas: treatmentCanvas.
		path ifNil: [ ^ self ].
		self
			drawOpaqueBandFrom: low
			to: high
			path: path
			onSpartaCanvas: treatmentCanvas.

		treatmentCanvas fill
			path: treatmentCanvas bounds;
			paint: (self gradientPaintFor: anElement raised: isRaised onSpartaCanvas: treatmentCanvas);
			composeIn;
			draw.

		aCanvas fill
			path: aCanvas bounds;
			paint: treatmentCanvas;
			draw ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawOpaqueBandFrom: aSignedDistance to: anotherSignedDistance path: aPath onSpartaCanvas: aCanvas [
	| low high |
	low := aSignedDistance min: anotherSignedDistance.
	high := aSignedDistance max: anotherSignedDistance.

	high <= 0 ifTrue: [
		^ self
			drawOpaqueOutsideBandFrom: high negated
			to: low negated
			path: aPath
			onSpartaCanvas: aCanvas ].

	low >= 0 ifTrue: [
		^ self
			drawOpaqueInsideBandFrom: low
			to: high
			path: aPath
			onSpartaCanvas: aCanvas ].

	"The interval crosses the element path. Draw the exterior half first because
	its interior-removal step intentionally clears everything inside the path."
	self
		drawOpaqueOutsideBandFrom: 0
		to: low negated
		path: aPath
		onSpartaCanvas: aCanvas.
	self
		drawOpaqueInsideBandFrom: 0
		to: high
		path: aPath
		onSpartaCanvas: aCanvas
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawOpaqueInsideBandFrom: aNearDistance to: aFarDistance path: aPath onSpartaCanvas: aCanvas [
	aFarDistance <= aNearDistance ifTrue: [ ^ self ].
	aCanvas clip
		by: aPath
		during: [
			aCanvas stroke
				path: aPath;
				paint: Color white;
				width: aFarDistance * 2.0;
				draw.
			aNearDistance isZero ifFalse: [
				aCanvas stroke
					path: aPath;
					paint: Color white;
					width: aNearDistance * 2.0;
					composeDestOut;
					draw ] ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawOpaqueOutsideBandFrom: aNearDistance to: aFarDistance path: aPath onSpartaCanvas: aCanvas [
	aFarDistance <= aNearDistance ifTrue: [ ^ self ].
	aCanvas stroke
		path: aPath;
		paint: Color white;
		width: aFarDistance * 2.0;
		draw.
	"Remove the complete interior half of the centered stroke."
	aCanvas fill
		path: aPath;
		paint: Color white;
		composeDestOut;
		draw.
	aNearDistance isZero ifFalse: [
		aCanvas stroke
			path: aPath;
			paint: Color white;
			width: aNearDistance * 2.0;
			composeDestOut;
			draw ]
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
				0.45 -> (highlight alpha: 0.12 * self opacity).
				0.55 -> (shadow alpha: 0.12 * self opacity).
				1 -> shadow } ]
			ifFalse: [ {
				0 -> shadow.
				0.45 -> (shadow alpha: 0.12 * self opacity).
				0.55 -> (highlight alpha: 0.12 * self opacity).
				1 -> highlight } ]);
		begin: start;
		end: finish;
		yourself
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

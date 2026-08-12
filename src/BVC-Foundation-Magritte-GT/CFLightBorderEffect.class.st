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
	| boundary start finish |
	bodyActive ifFalse: [ ^ self ].
	boundary := self bodyBoundaryCoordinateFor: anElement.
	start := bodyInside
		ifTrue: [ boundary ]
		ifFalse: [ boundary - self effectWidth ].
	finish := bodyInside
		ifTrue: [ boundary + self effectWidth ]
		ifFalse: [ boundary ].
	self
		drawTreatmentFrom: start
		to: finish
		raised: bodyRaised
		for: anElement
		onSpartaCanvas: aCanvas
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBorderTreatmentFor: anElement onSpartaCanvas: aCanvas [
	| boundary start finish |
	borderActive ifFalse: [ ^ self ].
	boundary := self borderOuterBoundaryCoordinateFor: anElement.
	start := borderInside
		ifTrue: [ boundary ]
		ifFalse: [ boundary - self effectWidth ].
	finish := borderInside
		ifTrue: [ boundary + self effectWidth ]
		ifFalse: [ boundary ].
	self
		drawTreatmentFrom: start
		to: finish
		raised: borderRaised
		for: anElement
		onSpartaCanvas: aCanvas
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawTreatmentFrom: aStartCoordinate to: anEndCoordinate raised: isRaised for: anElement onSpartaCanvas: aCanvas [
	"Coordinates are signed distances from the element geometry path. Positive
	coordinates are inside the element; negative coordinates are outside. Split
	a treatment crossing the geometry path into the two native path sides."
	| insideStart insideEnd outsideStart outsideEnd |
	anEndCoordinate > 0 ifTrue: [
		insideStart := aStartCoordinate max: 0.
		insideEnd := anEndCoordinate.
		insideEnd > insideStart ifTrue: [
			self
				drawTreatmentBandInside: true
				from: insideStart
				to: insideEnd
				raised: isRaised
				for: anElement
				onSpartaCanvas: aCanvas ] ].
	aStartCoordinate < 0 ifTrue: [
		outsideStart := (anEndCoordinate min: 0) abs.
		outsideEnd := aStartCoordinate abs.
		outsideEnd > outsideStart ifTrue: [
			self
				drawTreatmentBandInside: false
				from: outsideStart
				to: outsideEnd
				raised: isRaised
				for: anElement
				onSpartaCanvas: aCanvas ] ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawTreatmentBandInside: isInside from: innerDistance to: outerDistance raised: isRaised for: anElement onSpartaCanvas: aCanvas [
	"Build the treatment as an alpha mask first, using only solid strokes on the
	real element path. Sparta/Skia computes the parallel stroke contours, so the
	corner geometry remains aligned with arbitrary element geometry. Then paint
	the directional gradient through that mask with SrcIn composition."
	| path bounds gradient |
	path := self geometryPathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	bounds := anElement boundsInLocal expandBy: outerDistance + 2.
	gradient := self gradientPaintFor: anElement raised: isRaised onSpartaCanvas: aCanvas.

	aCanvas layer during: [
		"Start with the complete band at the requested distance from the real path."
		aCanvas stroke
			path: path;
			paint: Color white;
			width: outerDistance * 2.0;
			draw.

		"Turn the wide stroke into an annular slice when the treatment starts
		away from the geometry boundary."
		innerDistance > 0 ifTrue: [
			aCanvas stroke
				path: path;
				paint: Color white;
				width: innerDistance * 2.0;
				composeDestOut;
				draw ].

		"Keep only the requested side of the geometry path."
		aCanvas fill
			path: path;
			paint: Color white;
			in: [ :aFill |
				isInside
					ifTrue: [ aFill composeDestIn ]
					ifFalse: [ aFill composeDestOut ] ];
			draw.

		"The destination now contains only the treatment mask. Paint the
		directional gradient through it; SrcIn preserves only mask-covered pixels."
		aCanvas fill
			path: bounds;
			paint: gradient;
			composeIn;
			draw ]
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

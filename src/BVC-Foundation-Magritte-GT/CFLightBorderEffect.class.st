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
	bodyActive ifFalse: [ ^ self ].
	(bodyInside and: [ bodyRaised ]) ifTrue: [
		^ self drawRaisedBodyInsideFor: anElement onSpartaCanvas: aCanvas ].
	bodyInside
		ifTrue: [
			self
				drawRegionLightingFrom: [ :maskCanvas | self drawBorderRegionMaskFor: anElement onSpartaCanvas: maskCanvas ]
				clipTo: [ :targetCanvas | self clipCurrentLayerToBodyRegionFor: anElement onSpartaCanvas: targetCanvas ]
				raised: bodyRaised
				for: anElement
				onSpartaCanvas: aCanvas ]
		ifFalse: [
			self
				drawRegionLightingFrom: [ :maskCanvas | self drawBodyRegionMaskFor: anElement onSpartaCanvas: maskCanvas ]
				clipTo: [ :targetCanvas | self clipCurrentLayerToBorderRegionFor: anElement onSpartaCanvas: targetCanvas ]
				raised: bodyRaised
				for: anElement
				onSpartaCanvas: aCanvas ]
]


{ #category : 'private - drawing' }
CFLightBorderEffect >> drawRaisedBodyInsideFor: anElement onSpartaCanvas: aCanvas [
	"This is intentionally isolated while the eight treatment placements are verified.
	 For raised-body-inside, B is the shared border/body boundary. The border region
	 supplies the blurred light, but the result is composed into an exact body-region
	 destination mask before it is colourised. Nothing can survive on the border side
	 of B."
	| margin maskExtent maskCanvas magnitude vector highlightOffset shadowOffset |
	self effectWidth isZero ifTrue: [ ^ self ].
	margin := ((self effectWidth * 4.0) + anElement border width) ceiling.
	maskExtent := anElement extent + ((margin * 2) @ (margin * 2)).
	maskCanvas := aCanvas class extent: maskExtent.
	[
		maskCanvas transform
			by: [ :transform | transform translateBy: margin @ margin ]
			during: [ self drawBorderRegionMaskFor: anElement onSpartaCanvas: maskCanvas ].
		maskCanvas flush.

		magnitude := self effectWidth / 2.0.
		vector := lightDirection asBlocVector normalized asPoint * magnitude.
		highlightOffset := vector negated.
		shadowOffset := vector.

		self
			drawBodyInsideBlurredMask: maskCanvas
			offset: highlightOffset
			color: (self effectiveColor: highlightColor)
			margin: margin
			for: anElement
			onSpartaCanvas: aCanvas.
		self
			drawBodyInsideBlurredMask: maskCanvas
			offset: shadowOffset
			color: (self effectiveColor: shadowColor)
			margin: margin
			for: anElement
			onSpartaCanvas: aCanvas.

		self drawRaisedBodyInsideBoundaryFor: anElement onSpartaCanvas: aCanvas
	] ensure: [ maskCanvas release ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawRaisedBodyInsideBoundaryFor: anElement onSpartaCanvas: aCanvas [
	"Anchor the visible relief to B without constructing an offset path. B is the
	 inner edge of Bloc's native border stroke. I make a narrow band immediately
	 inside B by subtracting two strokes of the original geometry path, using the
	 same backend stroke rasterisation as BlOutskirts. The directional paint only
	 colours that band; it never moves its geometry."
	| path boundaryDistance ridgeWidth outerStrokeWidth innerStrokeWidth bounds center unit span begin end gradient |
	path := self geometryPathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	boundaryDistance := self bodyBoundaryCoordinateFor: anElement.
	ridgeWidth := (self effectWidth / 5.0) max: 1.0.
	outerStrokeWidth := (boundaryDistance + ridgeWidth) * 2.0.
	innerStrokeWidth := boundaryDistance * 2.0.
	bounds := anElement boundsInLocal.
	center := bounds center.
	unit := lightDirection asBlocVector normalized asPoint.
	span := (bounds width + bounds height) / 2.0.
	begin := center + (unit * span).
	end := center - (unit * span).
	gradient := aCanvas paint linearGradient
		begin: begin;
		end: end;
		stops: {
			0 -> (self effectiveColor: highlightColor).
			0.48 -> ((self effectiveColor: highlightColor) alpha: (self effectiveColor: highlightColor) alpha * 0.2).
			0.52 -> ((self effectiveColor: shadowColor) alpha: (self effectiveColor: shadowColor) alpha * 0.2).
			1 -> (self effectiveColor: shadowColor) }.

	aCanvas layer during: [
		aCanvas clip by: path during: [
			aCanvas stroke
				path: path;
				paint: Color white;
				width: outerStrokeWidth;
				draw.
			innerStrokeWidth isZero ifFalse: [
				aCanvas stroke
					path: path;
					paint: Color white;
					width: innerStrokeWidth;
					composeDestOut;
					draw ].
			aCanvas fill
				path: bounds;
				paint: gradient;
				composeIn;
				draw ] ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBodyInsideBlurredMask: aMaskCanvas offset: anOffset color: aColor margin: aMargin for: anElement onSpartaCanvas: aCanvas [
	"The Skia filter painter ignores Sparta drawOptions, so composing the blur with
	 SrcIn does not clip it to the body. Instead I use the canvas clip for the
	 element geometry, then remove the exact native-border overlap from the blurred
	 result. What remains is strictly the body side of B."
	| sigma destination fillBounds path |
	sigma := (self effectWidth / 2.0) max: 0.5.
	destination := (aMargin negated @ aMargin negated) + anOffset.
	fillBounds := anElement boundsInLocal expandBy: aMargin.
	path := self geometryPathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	aCanvas layer during: [
		aCanvas clip by: path during: [
			aCanvas filter
				area: aMaskCanvas bounds;
				to: destination;
				type: (aCanvas filters blur
					source: aMaskCanvas;
					stdDeviation: sigma);
				draw.
			anElement outskirts = BlOutskirts outside ifFalse: [
				self removeNativeBorderMaskFor: anElement path: path onSpartaCanvas: aCanvas ].
			aCanvas fill
				path: fillBounds;
				paint: aColor;
				composeIn;
				draw ] ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBorderTreatmentFor: anElement onSpartaCanvas: aCanvas [
	borderActive ifFalse: [ ^ self ].
	anElement border width isZero ifTrue: [ ^ self ].
	self drawBorderBoundaryLightingFor: anElement onSpartaCanvas: aCanvas
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBorderBoundaryLightingFor: anElement onSpartaCanvas: aCanvas [
	"The border treatment is anchored at the element geometry boundary A. Sparta's
	 box-shadow paint follows that exact path and is supported directly by Skia on
	 the recording canvas. For an inside treatment I clip to the element geometry;
	 for an outside treatment the native element paint later covers the inward half."
	| path availableWidth magnitude vector highlightOffset shadowOffset radius |
	path := self geometryPathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	availableWidth := self effectWidth min: anElement border width.
	availableWidth isZero ifTrue: [ ^ self ].
	radius := availableWidth max: 0.5.
	magnitude := availableWidth / 2.0.
	vector := lightDirection asBlocVector normalized asPoint * magnitude.
	highlightOffset := vector negated.
	shadowOffset := vector.
	borderInside
		ifTrue: [
			aCanvas clip by: path during: [
				self drawBorderShadowPath: path offset: highlightOffset color: (self effectiveColor: (borderRaised ifTrue: [ highlightColor ] ifFalse: [ shadowColor ])) radius: radius onSpartaCanvas: aCanvas.
				self drawBorderShadowPath: path offset: shadowOffset color: (self effectiveColor: (borderRaised ifTrue: [ shadowColor ] ifFalse: [ highlightColor ])) radius: radius onSpartaCanvas: aCanvas ] ]
		ifFalse: [
			self drawBorderShadowPath: path offset: highlightOffset color: (self effectiveColor: (borderRaised ifTrue: [ highlightColor ] ifFalse: [ shadowColor ])) radius: radius onSpartaCanvas: aCanvas.
			self drawBorderShadowPath: path offset: shadowOffset color: (self effectiveColor: (borderRaised ifTrue: [ shadowColor ] ifFalse: [ highlightColor ])) radius: radius onSpartaCanvas: aCanvas ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBorderShadowPath: aPath offset: anOffset color: aColor radius: aRadius onSpartaCanvas: aCanvas [
	aCanvas stroke
		path: aPath;
		paint: (aCanvas paint boxShadow
			color: aColor;
			offset: anOffset;
			radius: aRadius);
		width: 1;
		draw
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawRegionLightingFrom: aSourceMaskBlock clipTo: aTargetClipBlock raised: isRaised for: anElement onSpartaCanvas: aCanvas [
	"I derive lighting from the exact visual regions that Bloc itself paints. The
	 source region is blurred and directionally displaced across its shared boundary
	 with the target region. The result is then clipped back to the exact target
	 region. No secondary boundary path or radius is constructed."
	| margin maskExtent maskCanvas magnitude vector highlightOffset shadowOffset |
	self effectWidth isZero ifTrue: [ ^ self ].
	margin := ((self effectWidth * 4.0) + anElement border width) ceiling.
	maskExtent := anElement extent + ((margin * 2) @ (margin * 2)).
	maskCanvas := aCanvas class extent: maskExtent.
	[
		maskCanvas transform
			by: [ :transform | transform translateBy: margin @ margin ]
			during: [ aSourceMaskBlock value: maskCanvas ].
		maskCanvas flush.

		magnitude := self effectWidth / 2.0.
		vector := lightDirection asBlocVector normalized asPoint * magnitude.
		highlightOffset := vector negated.
		shadowOffset := vector.

		isRaised
			ifTrue: [
				self drawBlurredMask: maskCanvas offset: highlightOffset color: (self effectiveColor: highlightColor) margin: margin clipTo: aTargetClipBlock for: anElement onSpartaCanvas: aCanvas.
				self drawBlurredMask: maskCanvas offset: shadowOffset color: (self effectiveColor: shadowColor) margin: margin clipTo: aTargetClipBlock for: anElement onSpartaCanvas: aCanvas ]
			ifFalse: [
				self drawBlurredMask: maskCanvas offset: highlightOffset color: (self effectiveColor: shadowColor) margin: margin clipTo: aTargetClipBlock for: anElement onSpartaCanvas: aCanvas.
				self drawBlurredMask: maskCanvas offset: shadowOffset color: (self effectiveColor: highlightColor) margin: margin clipTo: aTargetClipBlock for: anElement onSpartaCanvas: aCanvas ]
	] ensure: [ maskCanvas release ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBlurredMask: aMaskCanvas offset: anOffset color: aColor margin: aMargin clipTo: aTargetClipBlock for: anElement onSpartaCanvas: aCanvas [
	| fillBounds sigma destination |
	fillBounds := anElement boundsInLocal expandBy: aMargin.
	sigma := (self effectWidth / 2.0) max: 0.5.
	destination := (aMargin negated @ aMargin negated) + anOffset.
	aCanvas layer during: [
		aCanvas filter
			area: aMaskCanvas bounds;
			to: destination;
			type: (aCanvas filters blur
				source: aMaskCanvas;
				stdDeviation: sigma);
			draw.
		aCanvas fill
			path: fillBounds;
			paint: aColor;
			composeIn;
			draw.
		aTargetClipBlock value: aCanvas ]
]

{ #category : 'private - regions' }
CFLightBorderEffect >> drawBodyRegionMaskFor: anElement onSpartaCanvas: aCanvas [
	| path |
	path := self geometryPathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	aCanvas fill
		path: path;
		paint: Color white;
		draw.
	anElement outskirts = BlOutskirts outside ifFalse: [
		self removeNativeBorderMaskFor: anElement path: path onSpartaCanvas: aCanvas ]
]

{ #category : 'private - regions' }
CFLightBorderEffect >> drawBorderRegionMaskFor: anElement onSpartaCanvas: aCanvas [
	| path width |
	path := self geometryPathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	width := anElement border width.
	width isZero ifTrue: [ ^ self ].
	anElement outskirts = BlOutskirts inside ifTrue: [
		^ aCanvas clip by: path during: [
			aCanvas stroke path: path; paint: Color white; width: width * 2.0; draw ] ].
	anElement outskirts = BlOutskirts centered ifTrue: [
		^ aCanvas stroke path: path; paint: Color white; width: width; draw ].
	anElement outskirts = BlOutskirts outside ifTrue: [
		aCanvas stroke path: path; paint: Color white; width: width * 2.0; draw.
		aCanvas fill path: path; paint: Color white; composeDestOut; draw ]
]

{ #category : 'private - regions' }
CFLightBorderEffect >> drawExteriorRegionMaskFor: anElement onSpartaCanvas: aCanvas [
	| path bounds |
	path := self geometryPathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	bounds := anElement boundsInLocal expandBy: ((self effectWidth * 4.0) + anElement border width).
	aCanvas fill path: bounds; paint: Color white; draw.
	aCanvas fill path: path; paint: Color white; composeDestOut; draw.
	self removeNativeBorderMaskFor: anElement path: path onSpartaCanvas: aCanvas
]

{ #category : 'private - regions' }
CFLightBorderEffect >> clipCurrentLayerToBodyRegionFor: anElement onSpartaCanvas: aCanvas [
	| path |
	path := self geometryPathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	aCanvas fill path: path; paint: Color white; composeDestIn; draw.
	anElement outskirts = BlOutskirts outside ifFalse: [
		self removeNativeBorderMaskFor: anElement path: path onSpartaCanvas: aCanvas ]
]

{ #category : 'private - regions' }
CFLightBorderEffect >> clipCurrentLayerToBorderRegionFor: anElement onSpartaCanvas: aCanvas [
	| path width |
	path := self geometryPathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	width := anElement border width.
	width isZero ifTrue: [
		aCanvas fill path: aCanvas bounds; paint: Color white; composeClear; draw.
		^ self ].
	anElement outskirts = BlOutskirts inside ifTrue: [
		aCanvas fill path: path; paint: Color white; composeDestIn; draw.
		aCanvas stroke path: path; paint: Color white; width: width * 2.0; composeDestIn; draw.
		^ self ].
	anElement outskirts = BlOutskirts centered ifTrue: [
		aCanvas stroke path: path; paint: Color white; width: width; composeDestIn; draw.
		^ self ].
	anElement outskirts = BlOutskirts outside ifTrue: [
		aCanvas stroke path: path; paint: Color white; width: width * 2.0; composeDestIn; draw.
		aCanvas fill path: path; paint: Color white; composeDestOut; draw ]
]

{ #category : 'private - regions' }
CFLightBorderEffect >> clipCurrentLayerToExteriorRegionFor: anElement onSpartaCanvas: aCanvas [
	| path width |
	path := self geometryPathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	aCanvas fill path: path; paint: Color white; composeDestOut; draw.
	width := anElement border width.
	width isZero ifTrue: [ ^ self ].
	anElement outskirts = BlOutskirts centered ifTrue: [
		aCanvas stroke path: path; paint: Color white; width: width; composeDestOut; draw ].
	anElement outskirts = BlOutskirts outside ifTrue: [
		aCanvas stroke path: path; paint: Color white; width: width * 2.0; composeDestOut; draw ]
]

{ #category : 'private - regions' }
CFLightBorderEffect >> removeNativeBorderMaskFor: anElement path: aPath onSpartaCanvas: aCanvas [
	| width |
	width := anElement border width.
	width isZero ifTrue: [ ^ self ].
	anElement outskirts = BlOutskirts inside ifTrue: [
		^ aCanvas clip by: aPath during: [
			aCanvas stroke path: aPath; paint: Color white; width: width * 2.0; composeDestOut; draw ] ].
	anElement outskirts = BlOutskirts centered ifTrue: [
		^ aCanvas stroke path: aPath; paint: Color white; width: width; composeDestOut; draw ].
	anElement outskirts = BlOutskirts outside ifTrue: [
		"The body region does not overlap an outside border. Callers that already
		 removed the element fill can safely remove the complete centered stroke."
		^ aCanvas stroke path: aPath; paint: Color white; width: width * 2.0; composeDestOut; draw ]
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

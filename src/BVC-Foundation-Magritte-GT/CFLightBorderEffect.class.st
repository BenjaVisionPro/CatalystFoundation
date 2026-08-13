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
	bodyInside
		ifTrue: [
			self
				drawRegionLightingFrom: [ :maskCanvas | self drawBorderRegionMaskFor: anElement onSpartaCanvas: maskCanvas ]
				target: [ :targetCanvas | self drawBodyRegionMaskFor: anElement onSpartaCanvas: targetCanvas ]
				raised: bodyRaised
				for: anElement
				onSpartaCanvas: aCanvas ]
		ifFalse: [
			self
				drawRegionLightingFrom: [ :maskCanvas | self drawBodyRegionMaskFor: anElement onSpartaCanvas: maskCanvas ]
				target: [ :targetCanvas | self drawBorderRegionMaskFor: anElement onSpartaCanvas: targetCanvas ]
				raised: bodyRaised
				for: anElement
				onSpartaCanvas: aCanvas ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBorderTreatmentFor: anElement onSpartaCanvas: aCanvas [
	borderActive ifFalse: [ ^ self ].
	anElement border width isZero ifTrue: [ ^ self ].
	borderInside
		ifTrue: [
			self
				drawRegionLightingFrom: [ :maskCanvas | self drawExteriorRegionMaskFor: anElement onSpartaCanvas: maskCanvas ]
				target: [ :targetCanvas | self drawBorderRegionMaskFor: anElement onSpartaCanvas: targetCanvas ]
				raised: borderRaised
				for: anElement
				onSpartaCanvas: aCanvas ]
		ifFalse: [
			self
				drawRegionLightingFrom: [ :maskCanvas | self drawBorderRegionMaskFor: anElement onSpartaCanvas: maskCanvas ]
				target: [ :targetCanvas | self drawExteriorRegionMaskFor: anElement onSpartaCanvas: targetCanvas ]
				raised: borderRaised
				for: anElement
				onSpartaCanvas: aCanvas ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawRegionLightingFrom: aSourceMaskBlock target: aTargetMaskBlock raised: isRaised for: anElement onSpartaCanvas: aCanvas [
	"I derive lighting from Bloc's exact visual regions. The target region is
	 established first. A full blurred source image is then composited with SrcIn,
	 so pixels outside either region are cleared across the complete treatment
	 extent. Finally the colour is applied with SrcIn through that intersection."
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
				self drawBlurredMask: maskCanvas offset: highlightOffset color: (self effectiveColor: highlightColor) margin: margin target: aTargetMaskBlock for: anElement onSpartaCanvas: aCanvas.
				self drawBlurredMask: maskCanvas offset: shadowOffset color: (self effectiveColor: shadowColor) margin: margin target: aTargetMaskBlock for: anElement onSpartaCanvas: aCanvas ]
			ifFalse: [
				self drawBlurredMask: maskCanvas offset: highlightOffset color: (self effectiveColor: shadowColor) margin: margin target: aTargetMaskBlock for: anElement onSpartaCanvas: aCanvas.
				self drawBlurredMask: maskCanvas offset: shadowOffset color: (self effectiveColor: highlightColor) margin: margin target: aTargetMaskBlock for: anElement onSpartaCanvas: aCanvas ]
	] ensure: [ maskCanvas release ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBlurredMask: aMaskCanvas offset: anOffset color: aColor margin: aMargin target: aTargetMaskBlock for: anElement onSpartaCanvas: aCanvas [
	| blurCanvas sigma imageRectangle |
	sigma := (self effectWidth / 2.0) max: 0.5.
	blurCanvas := aCanvas class extent: aMaskCanvas extent.
	[
		blurCanvas filter
			area: aMaskCanvas bounds;
			to: anOffset;
			type: (blurCanvas filters blur
				source: aMaskCanvas;
				stdDeviation: sigma);
			draw.
		blurCanvas flush.

		imageRectangle := (aMargin negated @ aMargin negated)
			extent: blurCanvas extent.
		aCanvas layer during: [
			aTargetMaskBlock value: aCanvas.
			blurCanvas snapshotDuring: [ :blurImage |
				aCanvas fill
					path: imageRectangle;
					paint: blurImage;
					composeIn;
					draw ].
			aCanvas fill
				path: imageRectangle;
				paint: aColor;
				composeIn;
				draw ]
	] ensure: [ blurCanvas release ]
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

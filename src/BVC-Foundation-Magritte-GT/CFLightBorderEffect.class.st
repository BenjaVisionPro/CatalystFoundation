Class {
	#name : 'CFLightBorderEffect',
	#superclass : 'BlElementEffect',
	#instVars : [
		'effectWidth',
		'depth',
		'lightOffsetFactor',
		'lightDirection',
		'highlightColor',
		'shadowColor',
		'style',
		'underlyingEffect'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'defaults' }
CFLightBorderEffect class >> defaultDepth [
	^ 4
]

{ #category : 'defaults' }
CFLightBorderEffect class >> defaultEffectWidth [
	^ 1
]

{ #category : 'drawing' }
CFLightBorderEffect >> applyAfterOnSpartaCanvas: aCanvas for: anElement [
	style = #raised ifTrue: [
		^ self drawRaisedBevelFor: anElement onSpartaCanvas: aCanvas ].
	style = #lowered ifTrue: [
		^ self drawLoweredBevelFor: anElement onSpartaCanvas: aCanvas ]
]

{ #category : 'geometry' }
CFLightBorderEffect >> computeBounds: aBlBounds [
	| effectBounds |
	effectBounds := underlyingEffect
		ifNil: [ aBlBounds ]
		ifNotNil: [ underlyingEffect computeBounds: aBlBounds ].
	^ style = #raised
		ifTrue: [ effectBounds expandBy: self outsideExtent ]
		ifFalse: [ effectBounds ]
]

{ #category : 'accessing' }
CFLightBorderEffect >> depth: aNumber [
	depth := aNumber rounded max: 0
]

{ #category : 'accessing' }
CFLightBorderEffect >> depth [
	"Existing live instances can predate the depth instance variable."
	^ depth ifNil: [ self class defaultDepth ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawClippedPathFor: anElement onSpartaCanvas: aCanvas paint: aPaint width: aWidth offset: aPoint [
	| path |
	path := self pathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	aCanvas clip
		by: path
		during: [
			self
				drawPath: path
				onSpartaCanvas: aCanvas
				paint: aPaint
				width: aWidth
				offset: aPoint ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawInnerBevelFor: anElement onSpartaCanvas: aCanvas lightColor: aLightColor lightDirection: aLightDirection shadowColor: aShadowColor shadowDirection: aShadowDirection [
	"The native inside border begins at the geometry edge. These fixed-width,
	alpha-blended layers are clipped inside that edge, over the border."
	self
		drawInnerLayersFor: anElement
		onSpartaCanvas: aCanvas
		color: aShadowColor
		direction: aShadowDirection.
	self
		drawInnerLayersFor: anElement
		onSpartaCanvas: aCanvas
		color: aLightColor
		direction: aLightDirection
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawInnerLayersFor: anElement onSpartaCanvas: aCanvas color: aColor direction: aVector [
	1 to: self depth do: [ :layer |
		self
			drawClippedPathFor: anElement
			onSpartaCanvas: aCanvas
			paint: (self layerColor: aColor at: layer)
			width: self effectWidth
			offset: aVector asPoint * (self lightOffset + ((layer - 1) * self effectWidth)) ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawLoweredBevelFor: anElement onSpartaCanvas: aCanvas [
	"A lowered surface reverses the raised bevel: the light-facing inner edge
	is shaded, while the opposing inner edge catches the highlight."
	self
		drawInnerBevelFor: anElement
		onSpartaCanvas: aCanvas
		lightColor: highlightColor
		lightDirection: self lightVector
		shadowColor: shadowColor
		shadowDirection: self shadowVector
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawPath: aPath onSpartaCanvas: aCanvas paint: aPaint width: aWidth offset: aPoint [
	aWidth <= 0 ifTrue: [ ^ self ].
	aCanvas transform
		by: [ :aTransform | aTransform translateBy: aPoint ]
		during: [
			aCanvas stroke
				path: aPath;
				paint: aPaint;
				width: aWidth;
				draw ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawRaisedBevelFor: anElement onSpartaCanvas: aCanvas [
	"Each pass follows a concentric outer path: the rectangle and its corner
	radii grow by the same amount. Unlike a translated path, it remains exactly
	aligned at straight edges and rounded corners."
	self depth to: 1 by: -1 do: [ :layer |
		self drawRaisedLayer: layer for: anElement onSpartaCanvas: aCanvas ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawRaisedLayer: aLayer for: anElement onSpartaCanvas: aCanvas [
	| path distance |
	distance := (aLayer - 0.5) * self effectWidth.
	path := self outerPathFor: anElement onSpartaCanvas: aCanvas distance: distance.
	path ifNil: [ ^ self ].
	(path respondsTo: #cornerRadii) ifFalse: [
		^ self
			drawPath: path
			onSpartaCanvas: aCanvas
			paint: (self layerColor: highlightColor at: aLayer)
			width: self effectWidth
			offset: 0 @ 0 ].
	self drawRoundedPerimeter: path layer: aLayer onSpartaCanvas: aCanvas
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawRoundedPerimeter: aRoundedRectangle layer: aLayer onSpartaCanvas: aCanvas [
	| rectangle radii left top right bottom |
	rectangle := aRoundedRectangle asRectangle.
	radii := aRoundedRectangle cornerRadii.
	left := rectangle left.
	top := rectangle top.
	right := rectangle right.
	bottom := rectangle bottom.
	self
		drawSegmentFrom: (left + radii topLeft) @ top
		to: (right - radii topRight) @ top
		normalAngle: Float pi negated / 2.0
		layer: aLayer
		onSpartaCanvas: aCanvas.
	self
		drawSegmentFrom: right @ (top + radii topRight)
		to: right @ (bottom - radii bottomRight)
		normalAngle: 0
		layer: aLayer
		onSpartaCanvas: aCanvas.
	self
		drawSegmentFrom: (right - radii bottomRight) @ bottom
		to: (left + radii bottomLeft) @ bottom
		normalAngle: Float pi / 2.0
		layer: aLayer
		onSpartaCanvas: aCanvas.
	self
		drawSegmentFrom: left @ (bottom - radii bottomLeft)
		to: left @ (top + radii topLeft)
		normalAngle: Float pi
		layer: aLayer
		onSpartaCanvas: aCanvas.
	self
		drawCornerAt: (left + radii topLeft) @ (top + radii topLeft)
		radius: radii topLeft
		from: Float pi
		to: Float pi * 1.5
		layer: aLayer
		onSpartaCanvas: aCanvas.
	self
		drawCornerAt: (right - radii topRight) @ (top + radii topRight)
		radius: radii topRight
		from: Float pi * 1.5
		to: Float pi * 2
		layer: aLayer
		onSpartaCanvas: aCanvas.
	self
		drawCornerAt: (right - radii bottomRight) @ (bottom - radii bottomRight)
		radius: radii bottomRight
		from: 0
		to: Float pi / 2.0
		layer: aLayer
		onSpartaCanvas: aCanvas.
	self
		drawCornerAt: (left + radii bottomLeft) @ (bottom - radii bottomLeft)
		radius: radii bottomLeft
		from: Float pi / 2.0
		to: Float pi
		layer: aLayer
		onSpartaCanvas: aCanvas
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawCornerAt: aCenterPoint radius: aRadius from: aStartAngle to: anEndAngle layer: aLayer onSpartaCanvas: aCanvas [
	"Skia has no generic gradient-path stroke. Subdivide the arc into solid,
	alpha-blended strokes instead. Each segment uses its outward normal, making
	the transition through the corner continuous rather than mask-shaped."
	| segmentCount angleStep |
	aRadius isZero ifTrue: [ ^ self ].
	segmentCount := 12.
	angleStep := (anEndAngle - aStartAngle) / segmentCount.
	0 to: segmentCount - 1 do: [ :anIndex |
		| segmentStart segmentEnd normalAngle path |
		segmentStart := aStartAngle + (anIndex * angleStep).
		segmentEnd := segmentStart + angleStep.
		normalAngle := (segmentStart + segmentEnd) / 2.0.
		path := aCanvas path
			absolute;
			arcAround: aCenterPoint
				radius: aRadius
				startAngle: segmentStart
				endAngle: segmentEnd;
			build.
		self
			drawPath: path
			onSpartaCanvas: aCanvas
			paint: (self colorForNormalAngle: normalAngle layer: aLayer)
			width: self effectWidth
			offset: 0 @ 0 ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> colorForNormalAngle: anAngle layer: aLayer [
	"The dot product of the outward edge normal and the light direction gives
	a continuous signed intensity: positive is the illuminated half; negative
	is the shaded half. The square-root normalisation retains full intensity on
	the cardinal edges for the default diagonal light."
	| intensity color |
	intensity := ((anAngle cos * self lightVector x) + (anAngle sin * self lightVector y)) * 2.0 sqrt.
	intensity >= 0
		ifTrue: [
			color := self layerColor: highlightColor at: aLayer.
			intensity := intensity min: 1.0 ]
		ifFalse: [
			color := self layerColor: shadowColor at: aLayer.
			intensity := intensity negated min: 1.0 ].
	^ color alpha: color alpha * intensity
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawSegmentFrom: aStartPoint to: anEndPoint normalAngle: anAngle layer: aLayer onSpartaCanvas: aCanvas [
	self
		drawPath: (aCanvas shape line: aStartPoint to: anEndPoint)
		onSpartaCanvas: aCanvas
		paint: (self colorForNormalAngle: anAngle layer: aLayer)
		width: self effectWidth
		offset: 0 @ 0
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawPathFor: anElement onSpartaCanvas: aCanvas paint: aPaint width: aWidth offset: aPoint [
	| path |
	path := self pathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	self
		drawPath: path
		onSpartaCanvas: aCanvas
		paint: aPaint
		width: aWidth
		offset: aPoint
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> effectWidth [
	^ effectWidth ifNil: [ self class defaultEffectWidth ]
]

{ #category : 'accessing' }
CFLightBorderEffect >> effectWidth: aNumber [
	effectWidth := aNumber max: 0
]

{ #category : 'accessing' }
CFLightBorderEffect >> highlightColor: aColor [
	highlightColor := aColor
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> layerColor: aColor at: aLayerIndex [
	| aDepth falloff |
	aDepth := self depth.
	aDepth isZero ifTrue: [ ^ Color transparent ].
	falloff := ((aDepth - aLayerIndex + 1) / aDepth) squared.
	^ aColor alpha: aColor alpha * falloff
]

{ #category : 'accessing' }
CFLightBorderEffect >> lightDirection: aVector [
	lightDirection := aVector
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> lightOffset [
	^ lightOffsetFactor * self effectWidth
]

{ #category : 'accessing' }
CFLightBorderEffect >> lightOffsetFactor: aNumber [
	lightOffsetFactor := aNumber max: 0
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> lightVector [
	^ lightDirection asBlocVector normalized
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> pathFor: anElement onSpartaCanvas: aCanvas [
	(anElement geometry respondsTo: #pathOnSpartaCanvas:of:) ifFalse: [ ^ nil ].
	^ anElement geometry pathOnSpartaCanvas: aCanvas of: anElement
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> outsideExtent [
	^ self depth * self effectWidth
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> outerPathFor: anElement onSpartaCanvas: aCanvas distance: aDistance [
	| path |
	path := self pathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ nil ].
	(path respondsTo: #cornerRadii) ifTrue: [
		^ aCanvas shape
			roundedRectangle: (path asRectangle expandBy: aDistance)
			radii: (self expandedRadiiOf: path cornerRadii by: aDistance) ].
	path isRectangle ifTrue: [ ^ path expandBy: aDistance ].
	^ nil
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> expandedRadiiOf: aCornerRadii by: aNumber [
	^ {
		aCornerRadii topLeft + aNumber.
		aCornerRadii topRight + aNumber.
		aCornerRadii bottomRight + aNumber.
		aCornerRadii bottomLeft + aNumber }
]

{ #category : 'drawing' }
CFLightBorderEffect >> paintOn: aCompositorPainter offset: anOffset for: anElement thenPaint: aBlock [
	underlyingEffect ifNil: [
		^ super
			paintOn: aCompositorPainter
			offset: anOffset
			for: anElement
			thenPaint: aBlock ].
	underlyingEffect
		paintOn: aCompositorPainter
		offset: anOffset
		for: anElement
		thenPaint: [ :anInnerPainter :anInnerOffset |
			aBlock cull: anInnerPainter cull: anInnerOffset.
			anInnerPainter canvas transform
				by: [ :aTransform | aTransform translateBy: anInnerOffset ]
				during: [ self applyAfterOnSpartaCanvas: anInnerPainter canvas for: anElement ] ]
]

{ #category : 'drawing' }
CFLightBorderEffect >> applyEffectOnSpartaCanvas: aCanvas for: anElement around: aBlock [
	underlyingEffect ifNil: [
		^ super
			applyEffectOnSpartaCanvas: aCanvas
			for: anElement
			around: aBlock ].
	underlyingEffect
		applyEffectOnSpartaCanvas: aCanvas
		for: anElement
		around: [ :anInnerCanvas |
			aBlock value: anInnerCanvas.
			self applyAfterOnSpartaCanvas: anInnerCanvas for: anElement ]
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> shadowVector [
	^ self lightVector negated
]

{ #category : 'accessing' }
CFLightBorderEffect >> shadowColor: aColor [
	shadowColor := aColor
]

{ #category : 'accessing' }
CFLightBorderEffect >> style: aSymbol [
	style := aSymbol
]

{ #category : 'accessing' }
CFLightBorderEffect >> underlyingEffect: anEffect [
	underlyingEffect := anEffect
]

{ #category : 'composition' }
CFLightBorderEffect >> wantsCompositionLayer [
	"Raised lighting expands beyond the element and cuts its interior from a
	temporary layer. Bloc must allocate that layer at the effect bounds."
	^ style = #raised
		or: [ underlyingEffect notNil and: [ underlyingEffect wantsCompositionLayer ] ]
]

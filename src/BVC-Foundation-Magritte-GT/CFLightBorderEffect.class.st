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
CFLightBorderEffect >> drawClippedPathFor: anElement onSpartaCanvas: aCanvas color: aColor offset: aPoint [
	| path |
	path := self pathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	aCanvas clip
		by: path
		during: [
			self
				drawPath: path
				onSpartaCanvas: aCanvas
				color: aColor
				offset: aPoint ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawOuterClippedPathFor: anElement onSpartaCanvas: aCanvas color: aColor offset: aPoint [
	| path |
	path := self pathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	aCanvas layer during: [
		self
			drawPath: path
			onSpartaCanvas: aCanvas
			color: aColor
			offset: aPoint.
		aCanvas fill
			path: path;
			paint: Color white;
			composeDestOut;
			draw ]
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
			color: (self layerColor: aColor at: layer)
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
CFLightBorderEffect >> drawPath: aPath onSpartaCanvas: aCanvas color: aColor offset: aPoint [
	aColor isTransparent ifTrue: [ ^ self ].
	self effectWidth <= 0 ifTrue: [ ^ self ].
	aCanvas transform
		by: [ :aTransform | aTransform translateBy: aPoint ]
		during: [
			aCanvas stroke
				path: aPath;
				paint: aColor;
				width: self effectWidth;
				draw ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawRaisedBevelFor: anElement onSpartaCanvas: aCanvas [
	"A raised surface lights and shades outside the native border's outer edge."
	self
		drawOuterLayersFor: anElement
		onSpartaCanvas: aCanvas
		color: highlightColor
		direction: self lightVector.
	self
		drawOuterLayersFor: anElement
		onSpartaCanvas: aCanvas
		color: shadowColor
		direction: self shadowVector
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawOuterLayersFor: anElement onSpartaCanvas: aCanvas color: aColor direction: aVector [
	1 to: self depth do: [ :layer |
		self
			drawOuterClippedPathFor: anElement
			onSpartaCanvas: aCanvas
			color: (self layerColor: aColor at: layer)
			offset: aVector asPoint * (self lightOffset + ((layer - 1) * self effectWidth)) ]
]

{ #category : 'accessing' }
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
	^ self lightOffset + ((self depth - 1) * self effectWidth) + (self effectWidth / 2.0)
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
	^ underlyingEffect notNil and: [ underlyingEffect wantsCompositionLayer ]
]

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
	"The raised passes remain solid alpha colours. The compositor's recorded
	gradient stroke is not rendered here; the two independent passes are both
	visible and preserve the underlying surface through alpha blending."
	self
		drawPathFor: anElement
		onSpartaCanvas: aCanvas
		paint: shadowColor
		width: self effectWidth
		offset: self shadowVector asPoint * self lightOffset.
	self
		drawPathFor: anElement
		onSpartaCanvas: aCanvas
		paint: highlightColor
		width: self effectWidth
		offset: self lightVector asPoint * self lightOffset
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

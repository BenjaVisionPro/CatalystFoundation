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
		'outerHighlightAlongLightDirection',
		'innerHighlightAlongLightDirection',
		'drawOuter',
		'drawInner',
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
	"Width of each alpha-blended bevel layer. It is independent from the
	element's BlBorder width."
	^ 1
]

{ #category : 'drawing' }
CFLightBorderEffect >> applyAfterOnSpartaCanvas: aCanvas for: anElement [
	drawInner ifTrue: [ self drawInnerLightingFor: anElement onSpartaCanvas: aCanvas ]
]

{ #category : 'drawing' }
CFLightBorderEffect >> applyBeforeOnSpartaCanvas: aCanvas for: anElement [
	drawOuter ifTrue: [ self drawOuterLightingFor: anElement onSpartaCanvas: aCanvas ]
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

{ #category : 'geometry' }
CFLightBorderEffect >> computeBounds: aBlBounds [
	| effectBounds |
	effectBounds := underlyingEffect
		ifNil: [ aBlBounds ]
		ifNotNil: [ underlyingEffect computeBounds: aBlBounds ].
	^ drawOuter
		ifTrue: [ effectBounds expandBy: self outsideExtent ]
		ifFalse: [ effectBounds ]
]

{ #category : 'accessing' }
CFLightBorderEffect >> depth [
	^ depth ifNil: [ self class defaultDepth ]
]

{ #category : 'accessing' }
CFLightBorderEffect >> depth: aNumber [
	depth := aNumber max: 0
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawInnerLightingFor: anElement onSpartaCanvas: aCanvas [
	| path |
	path := self pathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	aCanvas clip
		by: path
		during: [
			self
				drawLightingFor: anElement
				onSpartaCanvas: aCanvas
				highlightAlongLightDirection: innerHighlightAlongLightDirection ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawLightingFor: anElement onSpartaCanvas: aCanvas highlightAlongLightDirection: aBoolean [
	"The direction controls the highlight pass explicitly. This accommodates the
	opposite spatial meaning of the same transformed path inside and outside a
	closed geometry."
	aBoolean
		ifTrue: [
			self
				drawLightFor: anElement
				onSpartaCanvas: aCanvas
				color: highlightColor
				offset: self lightOffset;
				drawLightFor: anElement
				onSpartaCanvas: aCanvas
				color: shadowColor
				offset: self shadowOffset ]
		ifFalse: [
			self
				drawLightFor: anElement
				onSpartaCanvas: aCanvas
				color: shadowColor
				offset: self lightOffset;
				drawLightFor: anElement
				onSpartaCanvas: aCanvas
				color: highlightColor
				offset: self shadowOffset ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawLightFor: anElement onSpartaCanvas: aCanvas color: aColor offset: anOffset [
	| path unitDirection |
	path := self pathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	unitDirection := anOffset asBlocVector normalized.
	1 to: self depth do: [ :aLayer |
		aCanvas transform
			by: [ :aTransform |
				aTransform translateBy: (unitDirection asPoint * (lightOffsetFactor * aLayer)) ]
			during: [
				aCanvas stroke
					path: path;
					paint: (self layerColor: aColor at: aLayer);
					width: self effectWidth;
					draw ] ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> layerColor: aColor at: aLayer [
	| falloff |
	falloff := (self depth - aLayer + 1) / self depth.
	^ aColor alpha: aColor alpha * falloff squared
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawOuterLightingFor: anElement onSpartaCanvas: aCanvas [
	self
		drawLightingFor: anElement
		onSpartaCanvas: aCanvas
		highlightAlongLightDirection: outerHighlightAlongLightDirection
]

{ #category : 'accessing' }
CFLightBorderEffect >> drawInner: aBoolean [
	drawInner := aBoolean
]

{ #category : 'accessing' }
CFLightBorderEffect >> drawOuter: aBoolean [
	drawOuter := aBoolean
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

{ #category : 'initialization' }
CFLightBorderEffect >> initialize [
	super initialize.
	outerHighlightAlongLightDirection := true.
	innerHighlightAlongLightDirection := true.
	drawOuter := true.
	drawInner := false
]

{ #category : 'accessing' }
CFLightBorderEffect >> lightDirection: aVector [
	lightDirection := aVector
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> lightOffset [
	^ self lightVector asPoint * (lightOffsetFactor * self depth)
]

{ #category : 'accessing' }
CFLightBorderEffect >> lightOffsetFactor: aNumber [
	lightOffsetFactor := aNumber max: 0
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> lightVector [
	^ lightDirection asBlocVector normalized
]

{ #category : 'geometry' }
CFLightBorderEffect >> outsideExtent [
	^ self effectWidth + (self depth * 3) + self lightOffset asBlocVector length
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> pathFor: anElement onSpartaCanvas: aCanvas [
	(anElement geometry respondsTo: #pathOnSpartaCanvas:of:) ifFalse: [ ^ nil ].
	^ anElement geometry pathOnSpartaCanvas: aCanvas of: anElement
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
CFLightBorderEffect >> innerHighlightAlongLightDirection: aBoolean [
	innerHighlightAlongLightDirection := aBoolean
]

{ #category : 'accessing' }
CFLightBorderEffect >> outerHighlightAlongLightDirection: aBoolean [
	outerHighlightAlongLightDirection := aBoolean
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> shadowOffset [
	^ self lightOffset negated
]

{ #category : 'accessing' }
CFLightBorderEffect >> shadowColor: aColor [
	shadowColor := aColor
]

{ #category : 'accessing' }
CFLightBorderEffect >> underlyingEffect: anEffect [
	underlyingEffect := anEffect
]

{ #category : 'testing' }
CFLightBorderEffect >> wantsCompositionLayer [
	^ drawOuter
		or: [ underlyingEffect notNil and: [ underlyingEffect wantsCompositionLayer ] ]
]

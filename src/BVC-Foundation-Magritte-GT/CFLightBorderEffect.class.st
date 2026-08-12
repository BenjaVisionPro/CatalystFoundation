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
		'bodyRelief',
		'borderRelief',
		'underlyingEffect'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'defaults' }
CFLightBorderEffect class >> defaultDepth [ ^ 4 ]

{ #category : 'defaults' }
CFLightBorderEffect class >> defaultEffectWidth [ ^ 1 ]

{ #category : 'drawing' }
CFLightBorderEffect >> applyAfterOnSpartaCanvas: aCanvas for: anElement [
	self drawBodyAfterFor: anElement onSpartaCanvas: aCanvas.
	self drawBorderAfterFor: anElement onSpartaCanvas: aCanvas
]

{ #category : 'drawing' }
CFLightBorderEffect >> applyBeforeOnSpartaCanvas: aCanvas for: anElement [
	self drawBodyBeforeFor: anElement onSpartaCanvas: aCanvas.
	self drawBorderBeforeFor: anElement onSpartaCanvas: aCanvas
]

{ #category : 'drawing' }
CFLightBorderEffect >> applyEffectOnSpartaCanvas: aCanvas for: anElement around: aBlock [
	self applyBeforeOnSpartaCanvas: aCanvas for: anElement.
	underlyingEffect
		ifNil: [ aBlock cull: aCanvas ]
		ifNotNil: [ underlyingEffect applyEffectOnSpartaCanvas: aCanvas for: anElement around: aBlock ].
	self applyAfterOnSpartaCanvas: aCanvas for: anElement
]

{ #category : 'accessing' }
CFLightBorderEffect >> bodyRelief [ ^ bodyRelief ]

{ #category : 'accessing' }
CFLightBorderEffect >> bodyRelief: aSymbol [ bodyRelief := aSymbol ]

{ #category : 'accessing' }
CFLightBorderEffect >> borderRelief [ ^ borderRelief ]

{ #category : 'accessing' }
CFLightBorderEffect >> borderRelief: aSymbol [ borderRelief := aSymbol ]

{ #category : 'geometry' }
CFLightBorderEffect >> computeBounds: aBlBounds [
	| effectBounds |
	effectBounds := underlyingEffect
		ifNil: [ aBlBounds ]
		ifNotNil: [ underlyingEffect computeBounds: aBlBounds ].
	^ self drawsOutside
		ifTrue: [ effectBounds expandBy: self outsideExtent ]
		ifFalse: [ effectBounds ]
]

{ #category : 'accessing' }
CFLightBorderEffect >> depth [ ^ depth ifNil: [ self class defaultDepth ] ]

{ #category : 'accessing' }
CFLightBorderEffect >> depth: aNumber [ depth := aNumber max: 0 ]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBodyAfterFor: anElement onSpartaCanvas: aCanvas [
	bodyRelief = #lowered ifTrue: [
		self drawInsideLightingFor: anElement onSpartaCanvas: aCanvas highlightAlongLightDirection: true ].
	(bodyRelief = #raised and: [ borderRelief ~= #raised ]) ifTrue: [
		self drawInsideLightingFor: anElement onSpartaCanvas: aCanvas highlightAlongLightDirection: false ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBodyBeforeFor: anElement onSpartaCanvas: aCanvas [
	(bodyRelief = #raised and: [ borderRelief = #raised ]) ifTrue: [
		self drawOutsideLightingFor: anElement onSpartaCanvas: aCanvas highlightAlongLightDirection: true ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBorderAfterFor: anElement onSpartaCanvas: aCanvas [
	borderRelief = #raised ifTrue: [
		self drawInsideLightingFor: anElement onSpartaCanvas: aCanvas highlightAlongLightDirection: false ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBorderBeforeFor: anElement onSpartaCanvas: aCanvas [
	borderRelief = #lowered ifTrue: [
		self drawOutsideLightingFor: anElement onSpartaCanvas: aCanvas highlightAlongLightDirection: false ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawInsideLightingFor: anElement onSpartaCanvas: aCanvas highlightAlongLightDirection: aBoolean [
	| path |
	path := self pathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	aCanvas clip by: path during: [
		self drawLightingFor: anElement onSpartaCanvas: aCanvas highlightAlongLightDirection: aBoolean ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawLightingFor: anElement onSpartaCanvas: aCanvas highlightAlongLightDirection: aBoolean [
	aBoolean
		ifTrue: [
			self drawLightFor: anElement onSpartaCanvas: aCanvas color: highlightColor offset: self lightOffset.
			self drawLightFor: anElement onSpartaCanvas: aCanvas color: shadowColor offset: self shadowOffset ]
		ifFalse: [
			self drawLightFor: anElement onSpartaCanvas: aCanvas color: shadowColor offset: self lightOffset.
			self drawLightFor: anElement onSpartaCanvas: aCanvas color: highlightColor offset: self shadowOffset ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawLightFor: anElement onSpartaCanvas: aCanvas color: aColor offset: anOffset [
	| path unitDirection |
	path := self pathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	unitDirection := anOffset asBlocVector normalized.
	1 to: self depth do: [ :aLayer |
		aCanvas transform
			by: [ :aTransform | aTransform translateBy: (unitDirection asPoint * (lightOffsetFactor * aLayer)) ]
			during: [
				aCanvas stroke
					path: path;
					paint: (self layerColor: aColor at: aLayer);
					width: self effectWidth;
					draw ] ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawOutsideLightingFor: anElement onSpartaCanvas: aCanvas highlightAlongLightDirection: aBoolean [
	self drawLightingFor: anElement onSpartaCanvas: aCanvas highlightAlongLightDirection: aBoolean
]

{ #category : 'testing' }
CFLightBorderEffect >> drawsOutside [
	^ borderRelief = #lowered or: [ bodyRelief = #raised and: [ borderRelief = #raised ] ]
]

{ #category : 'accessing' }
CFLightBorderEffect >> effectWidth [ ^ effectWidth ifNil: [ self class defaultEffectWidth ] ]

{ #category : 'accessing' }
CFLightBorderEffect >> effectWidth: aNumber [ effectWidth := aNumber max: 0 ]

{ #category : 'accessing' }
CFLightBorderEffect >> highlightColor: aColor [ highlightColor := aColor ]

{ #category : 'initialization' }
CFLightBorderEffect >> initialize [
	super initialize.
	bodyRelief := #raised.
	borderRelief := #raised
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> layerColor: aColor at: aLayer [
	| falloff |
	falloff := (self depth - aLayer + 1) / self depth.
	^ aColor alpha: aColor alpha * falloff squared
]

{ #category : 'accessing' }
CFLightBorderEffect >> lightDirection: aVector [ lightDirection := aVector ]

{ #category : 'private - geometry' }
CFLightBorderEffect >> lightOffset [
	^ self lightVector asPoint * (lightOffsetFactor * self depth)
]

{ #category : 'accessing' }
CFLightBorderEffect >> lightOffsetFactor: aNumber [ lightOffsetFactor := aNumber max: 0 ]

{ #category : 'private - geometry' }
CFLightBorderEffect >> lightVector [ ^ lightDirection asBlocVector normalized ]

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
		ifNotNil: [ underlyingEffect paintOn: aCompositorPainter offset: anOffset for: anElement thenPaint: aBlock ].
	aCompositorPainter canvas transform
		by: [ :aTransform | aTransform translateBy: anOffset ]
		during: [ self applyAfterOnSpartaCanvas: aCompositorPainter canvas for: anElement ]
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> shadowOffset [ ^ self lightOffset negated ]

{ #category : 'accessing' }
CFLightBorderEffect >> shadowColor: aColor [ shadowColor := aColor ]

{ #category : 'accessing' }
CFLightBorderEffect >> underlyingEffect [ ^ underlyingEffect ]

{ #category : 'accessing' }
CFLightBorderEffect >> underlyingEffect: anEffect [
	underlyingEffect := anEffect.
	^ self
]

{ #category : 'testing' }
CFLightBorderEffect >> wantsCompositionLayer [
	^ self drawsOutside or: [ underlyingEffect notNil and: [ underlyingEffect wantsCompositionLayer ] ]
]

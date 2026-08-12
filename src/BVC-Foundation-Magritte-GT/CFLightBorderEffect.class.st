Class {
	#name : 'CFLightBorderEffect',
	#superclass : 'BlElementEffect',
	#instVars : [
		'width',
		'lightOffsetFactor',
		'lightDirection',
		'highlightColor',
		'shadowColor',
		'insetShadowColor',
		'insetShadowDepth',
		'style',
		'underlyingEffect'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'drawing' }
CFLightBorderEffect >> applyAfterOnSpartaCanvas: aCanvas for: anElement [
	self applyLightAfterOnSpartaCanvas: aCanvas for: anElement.
	underlyingEffect ifNotNil: [
		underlyingEffect applyAfterOnSpartaCanvas: aCanvas for: anElement ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> applyLightAfterOnSpartaCanvas: aCanvas for: anElement [
	style = #raised ifTrue: [
		^ self
			drawPathFor: anElement
			onSpartaCanvas: aCanvas
			color: highlightColor
			offset: self lightVector asPoint * self lightOffset ].

	(style = #inset or: [ style = #pressed ]) ifFalse: [ ^ self ].
	self drawSoftInsetShadowFor: anElement onSpartaCanvas: aCanvas.
	self
		drawClippedPathFor: anElement
		onSpartaCanvas: aCanvas
		color: highlightColor
		offset: self lightVector asPoint * self lightOffset
]

{ #category : 'drawing' }
CFLightBorderEffect >> applyBeforeOnSpartaCanvas: aCanvas for: anElement [
	underlyingEffect ifNotNil: [
		underlyingEffect applyBeforeOnSpartaCanvas: aCanvas for: anElement ].
	self applyLightBeforeOnSpartaCanvas: aCanvas for: anElement
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> applyLightBeforeOnSpartaCanvas: aCanvas for: anElement [
	style = #raised ifFalse: [ ^ self ].
	self
		drawPathFor: anElement
		onSpartaCanvas: aCanvas
		color: shadowColor
		offset: self shadowVector asPoint * self lightOffset
]

{ #category : 'geometry' }
CFLightBorderEffect >> computeBounds: aBlBounds [
	"The raised shadow extends beyond the native, centred BlBorder."
	| lightBounds |
	lightBounds := style = #raised
		ifTrue: [ aBlBounds expandBy: self lightOffset ]
		ifFalse: [ aBlBounds ].
	^ underlyingEffect
		ifNil: [ lightBounds ]
		ifNotNil: [ underlyingEffect computeBounds: lightBounds ]
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
CFLightBorderEffect >> drawPath: aPath onSpartaCanvas: aCanvas color: aColor offset: aPoint [
	aColor isTransparent ifTrue: [ ^ self ].
	width <= 0 ifTrue: [ ^ self ].
	aCanvas transform
		by: [ :aTransform | aTransform translateBy: aPoint ]
		during: [
			aCanvas stroke
				path: aPath;
				paint: aColor;
				width: width;
				draw ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawPathFor: anElement onSpartaCanvas: aCanvas color: aColor offset: aPoint [
	| path |
	path := self pathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	self drawPath: path onSpartaCanvas: aCanvas color: aColor offset: aPoint
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawSoftInsetShadowFor: anElement onSpartaCanvas: aCanvas [
	| layerCount direction |
	layerCount := insetShadowDepth rounded max: 0.
	layerCount isZero ifTrue: [ ^ self ].
	direction := self shadowVector.
	1 to: layerCount do: [ :layer |
		self
			drawClippedPathFor: anElement
			onSpartaCanvas: aCanvas
			color: (self insetShadowColorForLayer: layer of: layerCount)
			offset: direction asPoint * (self lightOffset + ((layer - 1) * width)) ]
]

{ #category : 'accessing' }
CFLightBorderEffect >> highlightColor: aColor [
	highlightColor := aColor
]

{ #category : 'accessing' }
CFLightBorderEffect >> insetShadowColor: aColor [
	insetShadowColor := aColor
]

{ #category : 'accessing' }
CFLightBorderEffect >> insetShadowColorForLayer: layerIndex of: layerCount [
	| progress falloff |
	layerCount <= 1 ifTrue: [ ^ insetShadowColor ].
	progress := (layerIndex - 1) / (layerCount - 1).
	falloff := (1 - progress) squared.
	^ insetShadowColor alpha: insetShadowColor alpha * falloff
]

{ #category : 'accessing' }
CFLightBorderEffect >> insetShadowDepth: aNumber [
	insetShadowDepth := aNumber max: 0
]

{ #category : 'accessing' }
CFLightBorderEffect >> lightDirection: aVector [
	lightDirection := aVector
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> lightOffset [
	"A factor keeps the directional light proportional to the native border width.
	The default (0.75 at width 1) preserves the original CFLitBorderAptitude dimensions."
	^ lightOffsetFactor * width
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

{ #category : 'accessing' }
CFLightBorderEffect >> shadowColor: aColor [
	shadowColor := aColor
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> shadowVector [
	^ self lightVector negated
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

{ #category : 'accessing' }
CFLightBorderEffect >> width: aNumber [
	width := aNumber max: 0
]

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
		'bodyInside',
		'borderRelief',
		'borderInside',
		'underlyingEffect',
		'opacity'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'defaults' }
CFLightBorderEffect class >> defaultDepth [ ^ 4 ]

{ #category : 'defaults' }
CFLightBorderEffect class >> defaultEffectWidth [ ^ 1 ]

{ #category : 'initialization' }
CFLightBorderEffect >> initialize [
	super initialize.
	bodyRelief := 1.
	bodyInside := true.
	borderRelief := 1.
	borderInside := false.
	opacity := 1.0
]

{ #category : 'drawing' }
CFLightBorderEffect >> applyEffectOnSpartaCanvas: aCanvas for: anElement around: aBlock [
	self drawOutsideTreatmentsFor: anElement onSpartaCanvas: aCanvas.
	underlyingEffect
		ifNil: [ aBlock cull: aCanvas ]
		ifNotNil: [ underlyingEffect applyEffectOnSpartaCanvas: aCanvas for: anElement around: aBlock ].
	self drawInsideTreatmentsFor: anElement onSpartaCanvas: aCanvas
]

{ #category : 'drawing' }
CFLightBorderEffect >> paintOn: aCompositorPainter offset: anOffset for: anElement thenPaint: aBlock [
	aCompositorPainter canvas transform
		by: [ :aTransform | aTransform translateBy: anOffset ]
		during: [ self drawOutsideTreatmentsFor: anElement onSpartaCanvas: aCompositorPainter canvas ].
	underlyingEffect
		ifNil: [ aBlock cull: aCompositorPainter cull: anOffset ]
		ifNotNil: [ underlyingEffect paintOn: aCompositorPainter offset: anOffset for: anElement thenPaint: aBlock ].
	aCompositorPainter canvas transform
		by: [ :aTransform | aTransform translateBy: anOffset ]
		during: [ self drawInsideTreatmentsFor: anElement onSpartaCanvas: aCompositorPainter canvas ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawOutsideTreatmentsFor: anElement onSpartaCanvas: aCanvas [
	(borderRelief ~= 0 and: [ borderInside not ]) ifTrue: [
		self drawTreatmentForRelief: borderRelief outsideGeometryOf: anElement onSpartaCanvas: aCanvas ].
	(bodyRelief ~= 0 and: [ bodyInside not ]) ifTrue: [
		self drawBodyOutsideTreatmentForRelief: bodyRelief of: anElement onSpartaCanvas: aCanvas ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawInsideTreatmentsFor: anElement onSpartaCanvas: aCanvas [
	(borderRelief ~= 0 and: [ borderInside ]) ifTrue: [
		self drawTreatmentForRelief: borderRelief insideGeometryOf: anElement onSpartaCanvas: aCanvas ].
	(bodyRelief ~= 0 and: [ bodyInside ]) ifTrue: [
		self drawBodyInsideTreatmentForRelief: bodyRelief of: anElement onSpartaCanvas: aCanvas ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawTreatmentForRelief: aRelief outsideGeometryOf: anElement onSpartaCanvas: aCanvas [
	"The element paint follows this pass, so the geometry itself masks the inward half of the centered stroke."
	self drawTreatmentForRelief: aRelief width: self treatmentWidth for: anElement onSpartaCanvas: aCanvas
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawTreatmentForRelief: aRelief insideGeometryOf: anElement onSpartaCanvas: aCanvas [
	| path |
	path := self pathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	aCanvas clip by: path during: [
		self drawTreatmentForRelief: aRelief width: self treatmentWidth for: anElement onSpartaCanvas: aCanvas ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBodyInsideTreatmentForRelief: aRelief of: anElement onSpartaCanvas: aCanvas [
	"Use the native border itself as the mask for the border band. This preserves arbitrary geometry and all BlOutskirts policies without synthesising a shape-specific inset path."
	self drawTreatmentForRelief: aRelief insideGeometryOf: anElement onSpartaCanvas: aCanvas.
	anElement border isVisible ifTrue: [
		anElement border drawOnSpartaCanvas: aCanvas of: anElement ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBodyOutsideTreatmentForRelief: aRelief of: anElement onSpartaCanvas: aCanvas [
	"This treatment occupies the native border side of the body boundary. With today's generic Bloc geometry API there is no independent path for that boundary, so use the native border band as the only geometry-independent mask."
	anElement border isVisible ifFalse: [ ^ self ].
	self drawTreatmentForRelief: aRelief insideGeometryOf: anElement onSpartaCanvas: aCanvas
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawTreatmentForRelief: aRelief width: aWidth for: anElement onSpartaCanvas: aCanvas [
	| path paint |
	path := self pathFor: anElement onSpartaCanvas: aCanvas.
	path ifNil: [ ^ self ].
	paint := self lightingPaintOn: aCanvas for: anElement relief: aRelief.
	aCanvas stroke
		path: path;
		paint: paint;
		width: aWidth;
		draw
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> lightingPaintOn: aCanvas for: anElement relief: aRelief [
	| bounds center direction span begin end firstColor lastColor |
	bounds := anElement boundsInLocal.
	center := bounds origin + (bounds extent / 2.0).
	direction := self lightVector asPoint.
	span := ((bounds extent x squared + bounds extent y squared) sqrt max: 1) / 2.0.
	begin := center - (direction * span).
	end := center + (direction * span).
	aRelief > 0
		ifTrue: [ firstColor := highlightColor. lastColor := shadowColor ]
		ifFalse: [ firstColor := shadowColor. lastColor := highlightColor ].
	firstColor := firstColor alpha: firstColor alpha * self opacity.
	lastColor := lastColor alpha: lastColor alpha * self opacity.
	^ aCanvas paint linearGradient
		stops: {
			0.0 -> firstColor.
			0.45 -> (firstColor alpha: firstColor alpha * 0.18).
			0.55 -> (lastColor alpha: lastColor alpha * 0.18).
			1.0 -> lastColor };
		begin: begin;
		end: end
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> treatmentWidth [
	^ (self effectWidth + (self depth * lightOffsetFactor)) * 2.0
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> pathFor: anElement onSpartaCanvas: aCanvas [
	(anElement geometry respondsTo: #pathOnSpartaCanvas:of:) ifFalse: [ ^ nil ].
	^ anElement geometry pathOnSpartaCanvas: aCanvas of: anElement
]

{ #category : 'private - geometry' }
CFLightBorderEffect >> lightVector [ ^ lightDirection asBlocVector normalized ]

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

{ #category : 'geometry' }
CFLightBorderEffect >> outsideExtent [ ^ self treatmentWidth / 2.0 + self effectWidth ]

{ #category : 'testing' }
CFLightBorderEffect >> drawsOutside [
	^ (borderRelief ~= 0 and: [ borderInside not ])
		or: [ bodyRelief ~= 0 and: [ bodyInside not ] ]
]

{ #category : 'testing' }
CFLightBorderEffect >> wantsCompositionLayer [
	^ self drawsOutside or: [ underlyingEffect notNil and: [ underlyingEffect wantsCompositionLayer ] ]
]

{ #category : 'accessing' }
CFLightBorderEffect >> effectWidth [ ^ effectWidth ifNil: [ self class defaultEffectWidth ] ]
{ #category : 'accessing' }
CFLightBorderEffect >> effectWidth: aNumber [ effectWidth := aNumber max: 0 ]
{ #category : 'accessing' }
CFLightBorderEffect >> depth [ ^ depth ifNil: [ self class defaultDepth ] ]
{ #category : 'accessing' }
CFLightBorderEffect >> depth: aNumber [ depth := aNumber max: 0 ]
{ #category : 'accessing' }
CFLightBorderEffect >> lightOffsetFactor: aNumber [ lightOffsetFactor := aNumber max: 0 ]
{ #category : 'accessing' }
CFLightBorderEffect >> lightDirection: aVector [ lightDirection := aVector ]
{ #category : 'accessing' }
CFLightBorderEffect >> highlightColor: aColor [ highlightColor := aColor ]
{ #category : 'accessing' }
CFLightBorderEffect >> shadowColor: aColor [ shadowColor := aColor ]
{ #category : 'accessing' }
CFLightBorderEffect >> bodyRelief [ ^ bodyRelief ]
{ #category : 'accessing' }
CFLightBorderEffect >> bodyRelief: aNumber [ bodyRelief := aNumber ]
{ #category : 'accessing' }
CFLightBorderEffect >> bodyInside [ ^ bodyInside ]
{ #category : 'accessing' }
CFLightBorderEffect >> bodyInside: aBoolean [ bodyInside := aBoolean ]
{ #category : 'accessing' }
CFLightBorderEffect >> borderRelief [ ^ borderRelief ]
{ #category : 'accessing' }
CFLightBorderEffect >> borderRelief: aNumber [ borderRelief := aNumber ]
{ #category : 'accessing' }
CFLightBorderEffect >> borderInside [ ^ borderInside ]
{ #category : 'accessing' }
CFLightBorderEffect >> borderInside: aBoolean [ borderInside := aBoolean ]
{ #category : 'accessing' }
CFLightBorderEffect >> underlyingEffect [ ^ underlyingEffect ]
{ #category : 'accessing' }
CFLightBorderEffect >> underlyingEffect: anEffect [ underlyingEffect := anEffect. ^ self ]


{ #category : 'accessing' }
CFLightBorderEffect >> opacity [ ^ opacity ifNil: [ 1.0 ] ]

{ #category : 'accessing' }
CFLightBorderEffect >> opacity: aNumber [ opacity := (aNumber max: 0.0) min: 1.0 ]

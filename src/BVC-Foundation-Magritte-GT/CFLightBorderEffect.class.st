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


{ #category : 'private - geometry' }
CFLightBorderEffect >> boundaryPathAt: aSignedInset for: anElement onSpartaCanvas: aCanvas [
    "Answer a path for a boundary parallel to the element geometry. Zero is the
    element geometry itself; positive values move inward and negative values
    move outward. For the concrete geometries used by Bloc forms we construct
    the true parallel geometry explicitly. For arbitrary vector paths there is
    no generic offset-path operation in Sparta, so only the zero boundary is
    supported rather than faking it."
    | geometry bounds |
    aSignedInset isZero ifTrue: [ ^ self geometryPathFor: anElement onSpartaCanvas: aCanvas ].
    geometry := anElement geometry.
    bounds := anElement boundsInLocal insetBy: aSignedInset.

    (geometry isKindOf: BlRoundedRectangleGeometry) ifTrue: [
        | radii |
        radii := geometry cornerRadii asArray collect: [ :each | (each - aSignedInset) max: 0 ].
        ^ aCanvas shape roundedRectangle: bounds radii: radii ].

    (geometry isKindOf: BlRectangleGeometry) ifTrue: [ ^ bounds ].

    (geometry isKindOf: BlEllipseGeometry) ifTrue: [
        ^ aCanvas shape ellipse: bounds ].

    ^ nil
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBodyTreatmentFor: anElement onSpartaCanvas: aCanvas [
    | bodyPath outerPath |
    bodyActive ifFalse: [ ^ self ].
    bodyPath := self
        boundaryPathAt: (self bodyBoundaryCoordinateFor: anElement)
        for: anElement
        onSpartaCanvas: aCanvas.
    bodyPath ifNil: [ ^ self ].

    bodyInside ifTrue: [
        ^ aCanvas clip
            by: bodyPath
            during: [ self
                drawReliefAround: bodyPath
                raised: bodyRaised
                onSpartaCanvas: aCanvas ] ].

    "Outside the body means the border side of the body boundary. With a native
    border, confine the treatment to that exact border band. Without a border,
    it is simply the exterior of the body."
    anElement border width isZero ifTrue: [
        ^ self
            drawReliefOutside: bodyPath
            raised: bodyRaised
            onSpartaCanvas: aCanvas ].

    outerPath := self
        boundaryPathAt: (self borderOuterBoundaryCoordinateFor: anElement)
        for: anElement
        onSpartaCanvas: aCanvas.
    outerPath ifNil: [ ^ self ].
    aCanvas clip
        by: outerPath
        during: [
            aCanvas layer during: [
                self drawReliefAround: bodyPath raised: bodyRaised onSpartaCanvas: aCanvas.
                aCanvas fill
                    path: bodyPath;
                    paint: Color white;
                    composeDestOut;
                    draw ] ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawBorderTreatmentFor: anElement onSpartaCanvas: aCanvas [
    | outerPath bodyPath |
    borderActive ifFalse: [ ^ self ].
    anElement border width isZero ifTrue: [ ^ self ].
    outerPath := self
        boundaryPathAt: (self borderOuterBoundaryCoordinateFor: anElement)
        for: anElement
        onSpartaCanvas: aCanvas.
    outerPath ifNil: [ ^ self ].

    borderInside ifFalse: [
        ^ self
            drawReliefOutside: outerPath
            raised: borderRaised
            onSpartaCanvas: aCanvas ].

    bodyPath := self
        boundaryPathAt: (self bodyBoundaryCoordinateFor: anElement)
        for: anElement
        onSpartaCanvas: aCanvas.
    bodyPath ifNil: [ ^ self ].
    aCanvas clip
        by: outerPath
        during: [
            aCanvas layer during: [
                self drawReliefAround: outerPath raised: borderRaised onSpartaCanvas: aCanvas.
                aCanvas fill
                    path: bodyPath;
                    paint: Color white;
                    composeDestOut;
                    draw ] ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawReliefAround: aPath raised: isRaised onSpartaCanvas: aCanvas [
    | lightVector offset highlight shadow |
    lightVector := lightDirection asBlocVector normalized asPoint.
    offset := lightVector * (self effectWidth / 2.0 max: 1.0).
    highlight := self effectiveColor: highlightColor.
    shadow := self effectiveColor: shadowColor.

    isRaised
        ifTrue: [
            self drawShadowOf: aPath color: highlight offset: offset radius: self effectWidth onSpartaCanvas: aCanvas.
            self drawShadowOf: aPath color: shadow offset: offset negated radius: self effectWidth onSpartaCanvas: aCanvas ]
        ifFalse: [
            self drawShadowOf: aPath color: shadow offset: offset radius: self effectWidth onSpartaCanvas: aCanvas.
            self drawShadowOf: aPath color: highlight offset: offset negated radius: self effectWidth onSpartaCanvas: aCanvas ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawReliefOutside: aPath raised: isRaised onSpartaCanvas: aCanvas [
    "Draw the shadows on an isolated layer and remove the interior of the same
    path. The surviving treatment is therefore geometrically outside that exact
    boundary; no translated or independently-rounded contour is involved."
    aCanvas layer during: [
        self drawReliefAround: aPath raised: isRaised onSpartaCanvas: aCanvas.
        aCanvas fill
            path: aPath;
            paint: Color white;
            composeDestOut;
            draw ]
]

{ #category : 'private - drawing' }
CFLightBorderEffect >> drawShadowOf: aPath color: aColor offset: anOffset radius: aRadius onSpartaCanvas: aCanvas [
    aCanvas stroke
        path: aPath;
        paint: (aCanvas paint boxShadow
            color: aColor;
            offset: anOffset;
            radius: aRadius);
        width: self effectWidth;
        draw
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

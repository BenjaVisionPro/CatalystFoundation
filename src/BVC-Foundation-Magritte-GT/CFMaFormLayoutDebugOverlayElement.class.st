Class {
	#name : 'CFMaFormLayoutDebugOverlayElement',
	#superclass : 'BlElement',
	#instVars : [
		'targetElement',
		'enabled'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'instance creation' }
CFMaFormLayoutDebugOverlayElement class >> forTarget: anElement [
	^ self new
		targetElement: anElement;
		yourself
]

{ #category : 'accessing' }
CFMaFormLayoutDebugOverlayElement class >> overlayIn: anElement [
	^ anElement
		allChildrenBreadthFirstDetect: [ :eachElement |
			eachElement isKindOf: CFMaFormLayoutDebugOverlayElement ]
		ifFound: [ :anOverlay | anOverlay ]
]

{ #category : 'accessing' }
CFMaFormLayoutDebugOverlayElement class >> toggleIn: anElement [
	^ (self overlayIn: anElement)
		ifNotNil: [ :anOverlay |
			anOverlay toggleEnabled.
			anOverlay isEnabled ]
		ifNil: [ false ]
]

{ #category : 'drawing' }
CFMaFormLayoutDebugOverlayElement >> drawElementDebugBounds: anElement onSpartaCanvas: aCanvas [
	self
		drawRectangle: (self localRectangleFor: anElement bounds inLocal asRectangle of: anElement)
		onSpartaCanvas: aCanvas
		paint: (Color gray alpha: 0.45)
		dashed: true.
	self
		drawRectangle: (self localRectangleFor: anElement geometryBounds of: anElement)
		onSpartaCanvas: aCanvas
		paint: (Color red alpha: 0.45)
		dashed: true.
	self
		drawRectangle: (self localRectangleFor: anElement visualBounds of: anElement)
		onSpartaCanvas: aCanvas
		paint: (Color blue alpha: 0.45)
		dashed: false
]

{ #category : 'drawing' }
CFMaFormLayoutDebugOverlayElement >> drawOnSpartaCanvas: aCanvas [
	super drawOnSpartaCanvas: aCanvas.

	self isEnabled ifFalse: [ ^ self ].
	targetElement ifNil: [ ^ self ].
	targetElement withAllChildrenBreadthFirstDo: [ :eachElement |
		(eachElement == self or: [ eachElement isKindOf: CFMaFormLayoutDebugOverlayElement ])
			ifFalse: [ self drawElementDebugBounds: eachElement onSpartaCanvas: aCanvas ] ]
]

{ #category : 'drawing' }
CFMaFormLayoutDebugOverlayElement >> drawRectangle: aRectangle onSpartaCanvas: aCanvas paint: aPaint dashed: aBoolean [
	| aStroke |
	aStroke := aCanvas stroke
		path: aRectangle;
		paint: aPaint;
		width: 1.
	aBoolean ifTrue: [ aStroke dashPattern: #(4 4) ].
	aStroke draw
]

{ #category : 'initialization' }
CFMaFormLayoutDebugOverlayElement >> initialize [
	super initialize.

	enabled := false.
	self
		preventMouseEvents;
		matchParent;
		constraintsDo: [ :c |
			c ignoreByLayout.
			c ignored horizontal alignLeft.
			c ignored vertical alignTop ]
]

{ #category : 'geometry' }
CFMaFormLayoutDebugOverlayElement >> localRectangleFor: aRectangle of: anElement [
	| aBounds |
	aBounds := BlBounds fromRectangle: aRectangle.
	anElement localBoundsToGlobal: aBounds.
	self globalBoundsToLocal: aBounds.
	^ aBounds asRectangle
]


{ #category : 'accessing' }
CFMaFormLayoutDebugOverlayElement >> isEnabled [
	^ enabled ifNil: [ false ]
]

{ #category : 'accessing' }
CFMaFormLayoutDebugOverlayElement >> enabled: aBoolean [
	enabled := aBoolean.
	self invalidate
]

{ #category : 'accessing' }
CFMaFormLayoutDebugOverlayElement >> toggleEnabled [
	self enabled: self isEnabled not
]

{ #category : 'accessing' }
CFMaFormLayoutDebugOverlayElement >> targetElement [
	^ targetElement
]

{ #category : 'accessing' }
CFMaFormLayoutDebugOverlayElement >> targetElement: anElement [
	targetElement := anElement
]

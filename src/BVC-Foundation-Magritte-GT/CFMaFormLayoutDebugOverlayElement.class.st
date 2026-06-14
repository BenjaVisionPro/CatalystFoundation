Class {
	#name : 'CFMaFormLayoutDebugOverlayElement',
	#superclass : 'BlOverlayElement',
	#instVars : [
		'targetElement',
		'enabled',
		'hoveredElement'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'instance creation' }
CFMaFormLayoutDebugOverlayElement class >> forTarget: anElement [
	^ self new
		targetElement: anElement;
		attachTo: anElement;
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
CFMaFormLayoutDebugOverlayElement class >> debugIconOff [
	^ BrGlamorousVectorIcons debug
]

{ #category : 'accessing' }
CFMaFormLayoutDebugOverlayElement class >> debugIconOn [
	^ [ BrGlamorousVectorIcons debug asElement
		background: Color red;
		yourself ] asStencil
]

{ #category : 'accessing' }
CFMaFormLayoutDebugOverlayElement class >> setEnabled: aBoolean in: anElement button: aButton [
	^ (self overlayIn: anElement)
		ifNotNil: [ :anOverlay |
			anOverlay enabled: aBoolean.
			aButton icon: ((aBoolean
				ifTrue: [ self debugIconOn ]
				ifFalse: [ self debugIconOff ]) asElement).
			anOverlay isEnabled ]
		ifNil: [ false ]
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
	hoveredElement ifNil: [ ^ self ].
	(hoveredElement == self or: [ hoveredElement isKindOf: CFMaFormLayoutDebugOverlayElement ])
		ifTrue: [ ^ self ].

	self drawElementDebugBounds: hoveredElement onSpartaCanvas: aCanvas
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
	hoveredElement := nil
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
	aBoolean ifFalse: [ hoveredElement := nil ].
	self invalidate.
	targetElement ifNotNil: [ targetElement invalidate ]
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
	targetElement := anElement.
	self installHoverDebugHandlersOn: anElement
]

{ #category : 'private - events' }
CFMaFormLayoutDebugOverlayElement >> installHoverDebugHandlersOn: anElement [
	anElement
		addEventFilterOn: BlMouseMoveEvent
		do: [ :anEvent | self updateHoveredElementFrom: anEvent ].
	anElement
		addEventFilterOn: BlMouseLeaveEvent
		do: [ :anEvent | self clearHoveredElement ]
]

{ #category : 'private - events' }
CFMaFormLayoutDebugOverlayElement >> updateHoveredElementFrom: aMouseEvent [
	self isEnabled ifFalse: [ ^ self ].
	hoveredElement == aMouseEvent target ifTrue: [ ^ self ].
	hoveredElement := aMouseEvent target.
	self invalidate
]

{ #category : 'private - events' }
CFMaFormLayoutDebugOverlayElement >> clearHoveredElement [
	hoveredElement ifNil: [ ^ self ].
	hoveredElement := nil.
	self invalidate
]

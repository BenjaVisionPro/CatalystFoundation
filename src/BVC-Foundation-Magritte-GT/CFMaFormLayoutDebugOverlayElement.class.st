Class {
	#name : 'CFMaFormLayoutDebugOverlayElement',
	#superclass : 'BlOverlayElement',
	#instVars : [
		'targetElement',
		'enabled',
		'hoveredElement',
		'mouseMoveEventHandler',
		'mouseLeaveEventHandler'
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
CFMaFormLayoutDebugOverlayElement class >> targetFormElementIn: anElement [
	(anElement isKindOf: CFMaFormElement)
		ifTrue: [ ^ anElement ].

	^ anElement
		allChildrenBreadthFirstDetect: [ :eachElement |
			eachElement isKindOf: CFMaFormElement ]
		ifFound: [ :aFormElement | aFormElement ]
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
	| anOverlay aTargetElement |
	aBoolean
		ifTrue: [
			aTargetElement := self targetFormElementIn: anElement.
			aTargetElement ifNil: [
				aButton icon: self debugIconOff asElement.
				^ false ].

			anOverlay := self overlayIn: aTargetElement.
			anOverlay ifNil: [
				anOverlay := self forTarget: aTargetElement.
				anOverlay
				zIndex: 1000;
				enabled: true.
				aTargetElement addChild: anOverlay as: #layoutDebugOverlay ].

			anOverlay enabled: true.
			aButton icon: self debugIconOn asElement.
			^ true ].

	anOverlay := self overlayIn: anElement.
	anOverlay ifNotNil: [
		anOverlay detach.
		anOverlay removeFromParent ].
	aButton icon: self debugIconOff asElement.
	^ false
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
CFMaFormLayoutDebugOverlayElement >> targetElement [
	^ targetElement
]

{ #category : 'accessing' }
CFMaFormLayoutDebugOverlayElement >> targetElement: anElement [
	targetElement == anElement ifTrue: [ ^ self ].
	self uninstallHoverDebugHandlers.
	targetElement := anElement.
	self installHoverDebugHandlersOn: anElement
]

{ #category : 'private - events' }
CFMaFormLayoutDebugOverlayElement >> installHoverDebugHandlersOn: anElement [
	anElement ifNil: [ ^ self ].
	mouseMoveEventHandler := BlEventHandler
		on: BlMouseMoveEvent
		do: [ :anEvent | self updateHoveredElementFrom: anEvent ].
	mouseLeaveEventHandler := BlEventHandler
		on: BlMouseLeaveEvent
		do: [ :anEvent | self clearHoveredElement ].
	anElement
		addEventFilter: mouseMoveEventHandler;
		addEventFilter: mouseLeaveEventHandler
]

{ #category : 'private - events' }
CFMaFormLayoutDebugOverlayElement >> uninstallHoverDebugHandlers [
	targetElement ifNil: [ ^ self ].
	mouseMoveEventHandler ifNotNil: [
		targetElement removeEventFilter: mouseMoveEventHandler.
		mouseMoveEventHandler := nil ].
	mouseLeaveEventHandler ifNotNil: [
		targetElement removeEventFilter: mouseLeaveEventHandler.
		mouseLeaveEventHandler := nil ].
	hoveredElement := nil
]

{ #category : 'api - attaching / detaching' }
CFMaFormLayoutDebugOverlayElement >> detach [
	self uninstallHoverDebugHandlers.
	super detach.
	targetElement := nil
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

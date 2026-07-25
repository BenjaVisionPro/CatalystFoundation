Class {
	#name : 'CFPhysicsBodyOverlayElement',
	#superclass : 'BlElement',
	#instVars : [ 'body', 'context', 'listener', 'selected' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsBodyOverlayElement class >> on: aBodyState context: aContext [
	^ self new
		body: aBodyState;
		context: aContext;
		initializeRepresentation;
		yourself
]

{ #category : 'accessing' }
CFPhysicsBodyOverlayElement >> body [ ^ body ]

{ #category : 'accessing' }
CFPhysicsBodyOverlayElement >> body: aBodyState [ body := aBodyState ]

{ #category : 'accessing' }
CFPhysicsBodyOverlayElement >> context: aContext [ context := aContext ]

{ #category : 'testing' }
CFPhysicsBodyOverlayElement >> isSelected [
	^ selected
]

{ #category : 'accessing' }
CFPhysicsBodyOverlayElement >> selected: aBoolean [
	selected := aBoolean.
	self refreshBorder.
	^ self
]

{ #category : 'initialization' }
CFPhysicsBodyOverlayElement >> initializeRepresentation [
	selected := false.
	self
		constraintsDo: [ :c | c ignoreByLayout ];
		background: Color transparent;
		border: (BlBorder paint: (Color blue alpha: 0.65) width: 1);
		preventMeAndChildrenMouseEvents.
	listener := CFPhysicsBodyOverlayListener for: self.
	body shapeState element addEventHandler: listener.
	self refresh
]

{ #category : 'updating' }
CFPhysicsBodyOverlayElement >> refresh [
	| shape source sourceExtent origin xAxis yAxis xVector yVector scale rotation |
	shape := body shapeState.
	source := shape element.
	sourceExtent := source extent.
	origin := context overlayPoint: 0 @ 0 from: source.
	xAxis := context overlayPoint: sourceExtent x @ 0 from: source.
	yAxis := context overlayPoint: 0 @ sourceExtent y from: source.
	xVector := xAxis - origin.
	yVector := yAxis - origin.
	scale :=
		(sourceExtent x isZero
			ifTrue: [ 1.0 ]
			ifFalse: [ xVector r / sourceExtent x ])
		@
		(sourceExtent y isZero
			ifTrue: [ 1.0 ]
			ifFalse: [ yVector r / sourceExtent y ]).
	rotation := xVector theta radiansToDegrees.
	self
		geometry: source geometry copy;
		size: sourceExtent;
		relocate: origin;
		transformDo: [ :aTransform |
			aTransform
				topLeftOrigin;
				scaleBy: scale;
				rotateBy: rotation ].
	self refreshBorder
]

{ #category : 'private - styling' }
CFPhysicsBodyOverlayElement >> refreshBorder [
	selected
		ifTrue: [
			self border: (BlBorder paint: (Color red alpha: 0.9) width: 3) ]
		ifFalse: [
			self border: (BlBorder
				paint: ((body isSensor ifTrue: [ Color orange ] ifFalse: [ Color blue ]) alpha: 0.65)
				width: 1) ].
	^ self
]

{ #category : 'updating' }
CFPhysicsBodyOverlayElement >> refreshOverlay [
	context overlay refresh
]

{ #category : 'controlling' }
CFPhysicsBodyOverlayElement >> release [
	body shapeState element removeEventHandler: listener
]

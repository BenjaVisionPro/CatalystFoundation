Class {
	#name : 'CFPhysicsBodyOverlayElement',
	#superclass : 'BlElement',
	#instVars : [ 'body', 'context', 'listener' ],
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

{ #category : 'initialization' }
CFPhysicsBodyOverlayElement >> initializeRepresentation [
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
	| shape |
	shape := body shapeState.
	self
		geometry: shape element geometry;
		size: shape extent;
		relocate: body position;
		transformDo: [ :aTransform |
			aTransform
				centerOrigin;
				rotateBy: body rotation radiansToDegrees ].
	self border: (BlBorder
		paint: ((body isSensor ifTrue: [ Color orange ] ifFalse: [ Color blue ]) alpha: 0.65)
		width: 1)
]

{ #category : 'updating' }
CFPhysicsBodyOverlayElement >> refreshOverlay [
	context overlay refresh
]

{ #category : 'controlling' }
CFPhysicsBodyOverlayElement >> release [
	body shapeState element removeEventHandler: listener
]

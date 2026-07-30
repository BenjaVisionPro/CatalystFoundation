Class {
	#name : 'CFPhysicsJointVisual',
	#superclass : 'BlLineElement',
	#instVars : [ 'joint', 'context', 'presentationRole', 'hitTarget' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsJointVisual class >> diagnosticOn: aJoint context: aContext [
	^ self new
		joint: aJoint;
		context: aContext;
		presentationRole: #diagnostic;
		initializeVisual;
		yourself
]

{ #category : 'instance creation' }
CFPhysicsJointVisual class >> selectionOn: aJoint context: aContext [
	^ self new
		joint: aJoint;
		context: aContext;
		presentationRole: #selection;
		initializeVisual;
		yourself
]

{ #category : 'accessing' }
CFPhysicsJointVisual >> joint [ ^ joint ]

{ #category : 'accessing' }
CFPhysicsJointVisual >> joint: aJoint [ joint := aJoint ]

{ #category : 'accessing' }
CFPhysicsJointVisual >> context: aContext [ context := aContext ]

{ #category : 'accessing' }
CFPhysicsJointVisual >> presentationRole [ ^ presentationRole ]

{ #category : 'accessing' }
CFPhysicsJointVisual >> presentationRole: aSymbol [ presentationRole := aSymbol ]

{ #category : 'testing' }
CFPhysicsJointVisual >> isDiagnostic [ ^ presentationRole = #diagnostic ]

{ #category : 'testing' }
CFPhysicsJointVisual >> isSelection [ ^ presentationRole = #selection ]

{ #category : 'testing' }
CFPhysicsJointVisual >> matchesSelection: anObject [
	^ self isSelection and: [ joint == anObject ]
]

{ #category : 'testing' }
CFPhysicsJointVisual >> hitTarget [ ^ hitTarget ]

{ #category : 'testing' }
CFPhysicsJointVisual >> includesEventTarget: anElement [
	^ anElement == self or: [ anElement == hitTarget ]
]

{ #category : 'testing' }
CFPhysicsJointVisual >> jointForEventTarget: anElement [
	^ (self includesEventTarget: anElement)
		ifTrue: [ joint ]
		ifFalse: [ nil ]
]

{ #category : 'initialization' }
CFPhysicsJointVisual >> initializeVisual [
	self
		fromAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		toAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		border: (BlBorder paint: (Color blue muchDarker alpha: 0.8) width: 1);
		constraintsDo: [ :constraints | constraints ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		fromHead: self newEndpointMarker;
		toHead: self newEndpointMarker.
	hitTarget := self newHitTarget.
	self isSelection ifTrue: [
		self
			border: (BlBorder paint: (Color red alpha: 0.9) width: 3);
			zIndex: 2 ]
]

{ #category : 'private - building' }
CFPhysicsJointVisual >> newEndpointMarker [
	^ BlArrowheadCircle new
		scale: 6.0;
		background: (Color blue muchDarker alpha: 0.9);
		border: (BlBorder paint: (Color blue muchDarker alpha: 0.9) width: 1);
		yourself
]

{ #category : 'private - building' }
CFPhysicsJointVisual >> newHitTarget [
	^ BlLineElement new
		fromAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		toAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		border: (BlBorder paint: Color transparent width: 12);
		constraintsDo: [ :constraints | constraints ignoreByLayout ];
		preventChildrenMouseEvents;
		yourself
]

{ #category : 'installing' }
CFPhysicsJointVisual >> addTo: aParentElement [
	aParentElement
		addChild: self;
		addChild: hitTarget.
	^ self
]

{ #category : 'updating' }
CFPhysicsJointVisual >> update [
	| points firstPoint secondPoint |
	points := joint endpointPair worldPoints.
	firstPoint := context
		overlayPointFromWorld: points first
		attachedTo: joint endpointPair bodyA.
	secondPoint := context
		overlayPointFromWorld: points second
		attachedTo: joint endpointPair bodyB.
	self
		fromAnchor: (BlAbsolutePositionAnchor position: firstPoint);
		toAnchor: (BlAbsolutePositionAnchor position: secondPoint).
	hitTarget
		fromAnchor: (BlAbsolutePositionAnchor position: firstPoint);
		toAnchor: (BlAbsolutePositionAnchor position: secondPoint).
	self requestLayout.
	hitTarget requestLayout.
	^ self
]

{ #category : 'removing' }
CFPhysicsJointVisual >> remove [
	self hasParent ifTrue: [ self removeFromParent ].
	hitTarget hasParent ifTrue: [ hitTarget removeFromParent ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsJointVisual >> release [ ^ self remove ]

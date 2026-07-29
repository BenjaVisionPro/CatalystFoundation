Class {
	#name : 'CFPhysicsSpringVisual',
	#superclass : 'BlLineElement',
	#instVars : [ 'spring', 'context', 'presentationRole' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsSpringVisual class >> diagnosticOn: aSpring context: aContext [
	^ self new
		spring: aSpring;
		context: aContext;
		presentationRole: #diagnostic;
		initializeVisual;
		yourself
]

{ #category : 'instance creation' }
CFPhysicsSpringVisual class >> selectionOn: aSpring context: aContext [
	^ self new
		spring: aSpring;
		context: aContext;
		presentationRole: #selection;
		initializeVisual;
		yourself
]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> spring [ ^ spring ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> spring: aSpring [ spring := aSpring ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> context: aContext [ context := aContext ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> presentationRole [ ^ presentationRole ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> presentationRole: aSymbol [ presentationRole := aSymbol ]

{ #category : 'testing' }
CFPhysicsSpringVisual >> isDiagnostic [ ^ presentationRole = #diagnostic ]

{ #category : 'testing' }
CFPhysicsSpringVisual >> isSelection [ ^ presentationRole = #selection ]

{ #category : 'initialization' }
CFPhysicsSpringVisual >> initializeVisual [
	self
		fromAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		toAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		border: (BlBorder paint: (Color darkGray alpha: 0.75) width: 1);
		constraintsDo: [ :c | c ignoreByLayout ];
		preventMeAndChildrenMouseEvents.
	self
		fromHead: self newEndpointMarker;
		toHead: self newEndpointMarker.
	self isSelection ifTrue: [ self zIndex: 2 ]
]

{ #category : 'private - building' }
CFPhysicsSpringVisual >> newEndpointMarker [
	^ BlArrowheadCircle new
		scale: 6.0;
		background: (Color darkGray alpha: 0.9);
		border: (BlBorder paint: (Color darkGray alpha: 0.9) width: 1);
		yourself
]

{ #category : 'installing' }
CFPhysicsSpringVisual >> addTo: aParentElement [
	aParentElement addChild: self.
	^ self
]

{ #category : 'updating' }
CFPhysicsSpringVisual >> update [
	| points firstPoint secondPoint |
	points := spring endpointPair worldPoints.
	firstPoint := context overlayPointFromWorld: points first.
	secondPoint := context overlayPointFromWorld: points second.
	self
		fromAnchor: (BlAbsolutePositionAnchor position: firstPoint);
		toAnchor: (BlAbsolutePositionAnchor position: secondPoint).
	^ self
]

{ #category : 'removing' }
CFPhysicsSpringVisual >> remove [
	self hasParent ifTrue: [ self removeFromParent ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsSpringVisual >> release [ ^ self remove ]

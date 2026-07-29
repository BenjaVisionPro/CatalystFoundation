Class {
	#name : 'CFPhysicsSpringVisual',
	#superclass : 'BlLineElement',
	#instVars : [ 'spring', 'context', 'presentationRole', 'restLengthMarker', 'hitTarget' ],
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
CFPhysicsSpringVisual >> restLengthMarker [ ^ restLengthMarker ]

{ #category : 'testing' }
CFPhysicsSpringVisual >> hitTarget [ ^ hitTarget ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> presentationRole [ ^ presentationRole ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> presentationRole: aSymbol [ presentationRole := aSymbol ]

{ #category : 'testing' }
CFPhysicsSpringVisual >> isDiagnostic [ ^ presentationRole = #diagnostic ]

{ #category : 'testing' }
CFPhysicsSpringVisual >> isSelection [ ^ presentationRole = #selection ]

{ #category : 'testing' }
CFPhysicsSpringVisual >> matchesSelection: anObject [
	^ self isSelection and: [ spring == anObject ]
]

{ #category : 'testing' }
CFPhysicsSpringVisual >> springForEventTarget: anElement [
	^ (self includesEventTarget: anElement)
		ifTrue: [ spring ]
		ifFalse: [ nil ]
]

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
	restLengthMarker := self newRestLengthMarker.
	hitTarget := self newHitTarget.
	self updateBorder.
	self isSelection ifTrue: [ self zIndex: 2 ]
]

{ #category : 'private - building' }
CFPhysicsSpringVisual >> newHitTarget [
	^ BlLineElement new
		fromAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		toAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		border: (BlBorder paint: Color transparent width: 12);
		constraintsDo: [ :c | c ignoreByLayout ];
		preventChildrenMouseEvents;
		yourself
]

{ #category : 'private - building' }
CFPhysicsSpringVisual >> newEndpointMarker [
	^ BlArrowheadCircle new
		scale: 6.0;
		background: (Color darkGray alpha: 0.9);
		border: (BlBorder paint: (Color darkGray alpha: 0.9) width: 1);
		yourself
]

{ #category : 'private - building' }
CFPhysicsSpringVisual >> newRestLengthMarker [
	^ BlElement new
		geometry: (BlPolygonGeometry vertices: { 4 @ 0. 8 @ 4. 4 @ 8. 0 @ 4 });
		size: 8 @ 8;
		background: (Color darkGray alpha: 0.9);
		constraintsDo: [ :c | c ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		zIndex: 1;
		yourself
]

{ #category : 'private - styling' }
CFPhysicsSpringVisual >> updateBorder [
	self isSelection
		ifTrue: [ self border: (BlBorder paint: (Color red alpha: 0.9) width: 3) ]
		ifFalse: [ self border: (BlBorder paint: (Color darkGray alpha: 0.75) width: 1) ]
]

{ #category : 'installing' }
CFPhysicsSpringVisual >> addTo: aParentElement [
	aParentElement
		addChild: self;
		addChild: restLengthMarker;
		addChild: hitTarget.
	^ self
]

{ #category : 'updating' }
CFPhysicsSpringVisual >> update [
	| points firstPoint secondPoint displacement distance restPoint |
	points := spring endpointPair worldPoints.
	firstPoint := context overlayPointFromWorld: points first.
	secondPoint := context overlayPointFromWorld: points second.
	self
		fromAnchor: (BlAbsolutePositionAnchor position: firstPoint);
		toAnchor: (BlAbsolutePositionAnchor position: secondPoint).
	hitTarget
		fromAnchor: (BlAbsolutePositionAnchor position: firstPoint);
		toAnchor: (BlAbsolutePositionAnchor position: secondPoint).
	self requestLayout.
	hitTarget requestLayout.
	displacement := points second - points first.
	distance := displacement r.
	distance isZero
		ifTrue: [ restLengthMarker visibility: BlVisibility gone ]
		ifFalse: [
			restPoint := points first + ((displacement / distance) * spring restLength value asFloat).
			restLengthMarker
				relocate: (context overlayPointFromWorld: restPoint) - (4 @ 4);
				visibility: BlVisibility visible ].
	^ self
]

{ #category : 'testing' }
CFPhysicsSpringVisual >> includesEventTarget: anElement [
	^ anElement == self or: [ anElement == hitTarget ]
]

{ #category : 'removing' }
CFPhysicsSpringVisual >> remove [
	self hasParent ifTrue: [ self removeFromParent ].
	restLengthMarker hasParent ifTrue: [ restLengthMarker removeFromParent ].
	hitTarget hasParent ifTrue: [ hitTarget removeFromParent ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsSpringVisual >> release [ ^ self remove ]

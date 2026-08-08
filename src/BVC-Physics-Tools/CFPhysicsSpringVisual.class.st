"I render one Physics spring inside an overlay. I show its endpoints and rest length for either diagnostic or selection presentation."
Class {
	#name : 'CFPhysicsSpringVisual',
	#superclass : 'BlLineElement',
	#instVars : [ 'spring', 'context', 'presentationRole', 'restLengthMarker', 'hitTarget', 'fromSelectionHandle', 'toSelectionHandle' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
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

{ #category : 'accessing' }
CFPhysicsSpringVisual >> fromSelectionHandle [ ^ fromSelectionHandle ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> toSelectionHandle [ ^ toSelectionHandle ]

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
	self isSelection
		ifTrue: [
			fromSelectionHandle := self newSelectionHandle.
			toSelectionHandle := self newSelectionHandle ]
		ifFalse: [
			self
				fromHead: self newEndpointMarker;
				toHead: self newEndpointMarker ].
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
CFPhysicsSpringVisual >> newSelectionHandle [
	^ BlElement new
		geometry: BlCircleGeometry new;
		background: (Color red alpha: 0.9);
		border: (BlBorder paint: (Color red alpha: 0.95) width: 1);
		constraintsDo: [ :constraints | constraints ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		zIndex: 3;
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
	fromSelectionHandle ifNotNil: [ aParentElement addChild: fromSelectionHandle ].
	toSelectionHandle ifNotNil: [ aParentElement addChild: toSelectionHandle ].
	^ self
]

{ #category : 'private - updating' }
CFPhysicsSpringVisual >> updateLine: aLine from: firstPoint to: secondPoint [
	(aLine fromAnchor position = firstPoint and: [ aLine toAnchor position = secondPoint ])
		ifTrue: [ ^ aLine ].
	aLine fromAnchor position: firstPoint.
	aLine toAnchor position: secondPoint.
	aLine requestLayout.
	^ aLine
]

{ #category : 'updating' }
CFPhysicsSpringVisual >> update [
	| points firstPoint secondPoint displacement distance restPoint |
	points := spring endpointPair worldPoints.
	firstPoint := context
		overlayPointFromWorld: points first
		attachedTo: spring endpointPair bodyA.
	secondPoint := context
		overlayPointFromWorld: points second
		attachedTo: spring endpointPair bodyB.
	self updateSelectionHandlesFrom: firstPoint to: secondPoint worldPoints: points.
	self updateLine: self from: firstPoint to: secondPoint.
	self updateLine: hitTarget from: firstPoint to: secondPoint.
	displacement := points second - points first.
	distance := displacement r.
	distance isZero
		ifTrue: [ restLengthMarker visibility: BlVisibility gone ]
		ifFalse: [
			restPoint := firstPoint + ((secondPoint - firstPoint) * (spring length asFloat / distance)).
			restLengthMarker
				relocate: restPoint - (4 @ 4);
				visibility: BlVisibility visible ].
	^ self
]

{ #category : 'private - updating' }
CFPhysicsSpringVisual >> updateSelectionHandle: aHandle at: aPoint worldPoint: aWorldPoint [
	| diameter extent origin |
	diameter := 4.0 * (context overlayScaleAtWorldPoint: aWorldPoint).
	extent := diameter asPoint.
	(aHandle extent closeTo: extent) ifFalse: [ aHandle size: extent ].
	origin := aPoint - (extent / 2.0).
	aHandle position = origin ifFalse: [ aHandle relocate: origin ]
]

{ #category : 'private - updating' }
CFPhysicsSpringVisual >> updateSelectionHandlesFrom: firstPoint to: secondPoint worldPoints: worldPoints [
	self isSelection ifFalse: [ ^ self ].
	self
		updateSelectionHandle: fromSelectionHandle at: firstPoint worldPoint: worldPoints first;
		updateSelectionHandle: toSelectionHandle at: secondPoint worldPoint: worldPoints second
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
	fromSelectionHandle ifNotNil: [
		fromSelectionHandle hasParent ifTrue: [ fromSelectionHandle removeFromParent ] ].
	toSelectionHandle ifNotNil: [
		toSelectionHandle hasParent ifTrue: [ toSelectionHandle removeFromParent ] ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsSpringVisual >> release [ ^ self remove ]

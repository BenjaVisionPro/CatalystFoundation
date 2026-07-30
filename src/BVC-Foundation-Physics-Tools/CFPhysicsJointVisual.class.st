Class {
	#name : 'CFPhysicsJointVisual',
	#superclass : 'BlLineElement',
	#instVars : [ 'joint', 'context', 'presentationRole', 'hitTarget', 'restLengthMarker', 'rail', 'lowerLimitMarker', 'upperLimitMarker', 'pivotMarker', 'referenceRay', 'lowerAngleMarker', 'upperAngleMarker', 'allowedAngleArc', 'motorCue' ],
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
CFPhysicsJointVisual >> context [ ^ context ]

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

{ #category : 'accessing' }
CFPhysicsJointVisual >> restLengthMarker [ ^ restLengthMarker ]

{ #category : 'accessing' }
CFPhysicsJointVisual >> rail [ ^ rail ]

{ #category : 'accessing' }
CFPhysicsJointVisual >> lowerLimitMarker [ ^ lowerLimitMarker ]

{ #category : 'accessing' }
CFPhysicsJointVisual >> upperLimitMarker [ ^ upperLimitMarker ]

{ #category : 'accessing' }
CFPhysicsJointVisual >> pivotMarker [ ^ pivotMarker ]

{ #category : 'accessing' }
CFPhysicsJointVisual >> referenceRay [ ^ referenceRay ]

{ #category : 'accessing' }
CFPhysicsJointVisual >> lowerAngleMarker [ ^ lowerAngleMarker ]

{ #category : 'accessing' }
CFPhysicsJointVisual >> upperAngleMarker [ ^ upperAngleMarker ]

{ #category : 'accessing' }
CFPhysicsJointVisual >> allowedAngleArc [ ^ allowedAngleArc ]

{ #category : 'accessing' }
CFPhysicsJointVisual >> motorCue [ ^ motorCue ]

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
	restLengthMarker := self newRestLengthMarker.
	rail := self newRail.
	lowerLimitMarker := self newRailLimitMarker.
	upperLimitMarker := self newRailLimitMarker.
	pivotMarker := self newPivotMarker.
	referenceRay := self newAngularLine.
	lowerAngleMarker := self newAngularLine.
	upperAngleMarker := self newAngularLine.
	allowedAngleArc := self newAllowedAngleArc.
	motorCue := self newMotorCue.
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
CFPhysicsJointVisual >> newRestLengthMarker [
	| markerColor |
	markerColor := self isSelection
		ifTrue: [ Color red alpha: 0.9 ]
		ifFalse: [ Color blue muchDarker alpha: 0.9 ].
	^ BlElement new
		geometry: (BlPolygonGeometry vertices: { 4 @ 0. 8 @ 4. 4 @ 8. 0 @ 4 });
		size: 8 @ 8;
		background: markerColor;
		constraintsDo: [ :constraints | constraints ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		visibility: BlVisibility gone;
		zIndex: 1;
		yourself
]


{ #category : 'private - building' }
CFPhysicsJointVisual >> newRail [
	^ BlLineElement new
		fromAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		toAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		border: (BlBorder paint: (Color blue muchDarker alpha: 0.45) width: 2);
		constraintsDo: [ :constraints | constraints ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		visibility: BlVisibility gone;
		yourself
]

{ #category : 'private - building' }
CFPhysicsJointVisual >> newRailLimitMarker [
	^ BlLineElement new
		fromAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		toAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		border: (BlBorder paint: (Color blue muchDarker alpha: 0.8) width: 2);
		constraintsDo: [ :constraints | constraints ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		visibility: BlVisibility gone;
		yourself
]


{ #category : 'private - building' }
CFPhysicsJointVisual >> newPivotMarker [
	^ BlElement new
		geometry: BlCircleGeometry new;
		size: 10 @ 10;
		background: (Color blue muchDarker alpha: 0.25);
		border: (BlBorder paint: (Color blue muchDarker alpha: 0.9) width: 2);
		constraintsDo: [ :constraints | constraints ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		visibility: BlVisibility gone;
		zIndex: 1;
		yourself
]

{ #category : 'private - building' }
CFPhysicsJointVisual >> newAngularLine [
	^ BlLineElement new
		fromAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		toAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		border: (BlBorder paint: (Color blue muchDarker alpha: 0.75) width: 2);
		constraintsDo: [ :constraints | constraints ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		visibility: BlVisibility gone;
		yourself
]

{ #category : 'private - building' }
CFPhysicsJointVisual >> newAllowedAngleArc [
	^ BlElement new
		geometry: (BlAnnulusSectorGeometry new innerRadius: 0.82; outerRadius: 1.0);
		size: 56 @ 56;
		background: (Color blue muchDarker alpha: 0.18);
		constraintsDo: [ :constraints | constraints ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		visibility: BlVisibility gone;
		yourself
]

{ #category : 'private - building' }
CFPhysicsJointVisual >> newMotorCue [
	^ BlLineElement new
		fromAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		toAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		toHead: (BlArrowheadSimpleArrow new
			border: (BlBorder paint: (Color blue muchDarker alpha: 0.9) width: 2));
		border: (BlBorder paint: (Color blue muchDarker alpha: 0.8) width: 2);
		constraintsDo: [ :constraints | constraints ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		visibility: BlVisibility gone;
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
		addChild: rail;
		addChild: lowerLimitMarker;
		addChild: upperLimitMarker;
		addChild: restLengthMarker;
		addChild: allowedAngleArc;
		addChild: referenceRay;
		addChild: lowerAngleMarker;
		addChild: upperAngleMarker;
		addChild: motorCue;
		addChild: pivotMarker;
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
	joint
		updatePhysicsOverlayVisual: self
		from: firstPoint
		to: secondPoint
		worldPoints: points.
	^ self
]



{ #category : 'updating - joint decorations' }
CFPhysicsJointVisual >> hideRail [
	rail visibility: BlVisibility gone.
	lowerLimitMarker visibility: BlVisibility gone.
	upperLimitMarker visibility: BlVisibility gone
]

{ #category : 'updating - joint decorations' }
CFPhysicsJointVisual >> showRailFrom: firstPoint to: secondPoint [
	rail
		fromAnchor: (BlAbsolutePositionAnchor position: firstPoint);
		toAnchor: (BlAbsolutePositionAnchor position: secondPoint);
		visibility: BlVisibility visible.
	rail requestLayout
]

{ #category : 'updating - joint decorations' }
CFPhysicsJointVisual >> showRailLimitFrom: firstPoint to: secondPoint on: aMarker [
	aMarker
		fromAnchor: (BlAbsolutePositionAnchor position: firstPoint);
		toAnchor: (BlAbsolutePositionAnchor position: secondPoint);
		visibility: BlVisibility visible.
	aMarker requestLayout
]


{ #category : 'updating - joint decorations' }
CFPhysicsJointVisual >> hideRevoluteDecoration [
	pivotMarker visibility: BlVisibility gone.
	referenceRay visibility: BlVisibility gone.
	lowerAngleMarker visibility: BlVisibility gone.
	upperAngleMarker visibility: BlVisibility gone.
	allowedAngleArc visibility: BlVisibility gone.
	motorCue visibility: BlVisibility gone
]

{ #category : 'updating - joint decorations' }
CFPhysicsJointVisual >> showPivotAt: aPoint [
	pivotMarker
		relocate: aPoint - (5 @ 5);
		visibility: BlVisibility visible
]

{ #category : 'updating - joint decorations' }
CFPhysicsJointVisual >> showReferenceRayFrom: firstPoint to: secondPoint [
	referenceRay
		fromAnchor: (BlAbsolutePositionAnchor position: firstPoint);
		toAnchor: (BlAbsolutePositionAnchor position: secondPoint);
		visibility: BlVisibility visible.
	referenceRay requestLayout
]

{ #category : 'updating - joint decorations' }
CFPhysicsJointVisual >> showAngleLimitFrom: firstPoint to: secondPoint on: aMarker [
	aMarker
		fromAnchor: (BlAbsolutePositionAnchor position: firstPoint);
		toAnchor: (BlAbsolutePositionAnchor position: secondPoint);
		visibility: BlVisibility visible.
	aMarker requestLayout
]

{ #category : 'updating - joint decorations' }
CFPhysicsJointVisual >> showAllowedAngleFromDegrees: startDegrees toDegrees: endDegrees around: pivotPoint [
	allowedAngleArc geometry
		startAngle: startDegrees;
		endAngle: endDegrees.
	allowedAngleArc
		relocate: pivotPoint - (28 @ 28);
		visibility: BlVisibility visible
]

{ #category : 'updating - joint decorations' }
CFPhysicsJointVisual >> showMotorCueFrom: firstPoint to: secondPoint [
	motorCue
		fromAnchor: (BlAbsolutePositionAnchor position: firstPoint);
		toAnchor: (BlAbsolutePositionAnchor position: secondPoint);
		visibility: BlVisibility visible.
	motorCue requestLayout
]



{ #category : 'updating - joint decorations' }
CFPhysicsJointVisual >> showFixedLockFrom: firstPoint to: secondPoint direction: aDirection [
	| normal innerPoint outerPoint halfWidth |
	self showReferenceRayFrom: firstPoint to: secondPoint.
	normal := aDirection y negated @ aDirection x.
	halfWidth := 5.0.
	innerPoint := firstPoint + (aDirection * 12.0).
	outerPoint := secondPoint.
	self
		showAngleLimitFrom: innerPoint - (normal * halfWidth)
		to: innerPoint + (normal * halfWidth)
		on: lowerAngleMarker;
		showAngleLimitFrom: outerPoint - (normal * halfWidth)
		to: outerPoint + (normal * halfWidth)
		on: upperAngleMarker
]

{ #category : 'updating - joint decorations' }
CFPhysicsJointVisual >> hideRestLengthMarker [
	restLengthMarker visibility: BlVisibility gone
]

{ #category : 'updating - joint decorations' }
CFPhysicsJointVisual >> showRestLengthMarkerAtFraction: aNumber from: firstPoint to: secondPoint [
	| restPoint |
	restPoint := firstPoint + ((secondPoint - firstPoint) * aNumber).
	restLengthMarker
		relocate: restPoint - (4 @ 4);
		visibility: BlVisibility visible
]

{ #category : 'removing' }
CFPhysicsJointVisual >> remove [
	self hasParent ifTrue: [ self removeFromParent ].
	rail hasParent ifTrue: [ rail removeFromParent ].
	lowerLimitMarker hasParent ifTrue: [ lowerLimitMarker removeFromParent ].
	upperLimitMarker hasParent ifTrue: [ upperLimitMarker removeFromParent ].
	restLengthMarker hasParent ifTrue: [ restLengthMarker removeFromParent ].
	pivotMarker hasParent ifTrue: [ pivotMarker removeFromParent ].
	referenceRay hasParent ifTrue: [ referenceRay removeFromParent ].
	lowerAngleMarker hasParent ifTrue: [ lowerAngleMarker removeFromParent ].
	upperAngleMarker hasParent ifTrue: [ upperAngleMarker removeFromParent ].
	allowedAngleArc hasParent ifTrue: [ allowedAngleArc removeFromParent ].
	motorCue hasParent ifTrue: [ motorCue removeFromParent ].
	hitTarget hasParent ifTrue: [ hitTarget removeFromParent ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsJointVisual >> release [ ^ self remove ]

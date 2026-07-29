Class {
	#name : 'CFPhysicsSpringVisual',
	#superclass : 'BlElement',
	#instVars : [ 'spring', 'context', 'presentationRole', 'springLine', 'firstAnchorMarker', 'secondAnchorMarker', 'restMarker', 'firstPoint', 'secondPoint', 'restPoint' ],
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

{ #category : 'accessing' }
CFPhysicsSpringVisual >> springLine [ ^ springLine ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> firstAnchorMarker [ ^ firstAnchorMarker ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> secondAnchorMarker [ ^ secondAnchorMarker ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> restMarker [ ^ restMarker ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> firstPoint [ ^ firstPoint ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> secondPoint [ ^ secondPoint ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> restPoint [ ^ restPoint ]

{ #category : 'testing' }
CFPhysicsSpringVisual >> isSelection [ ^ presentationRole = #selection ]

{ #category : 'initialization' }
CFPhysicsSpringVisual >> initializeVisual [
	self
		constraintsDo: [ :c | c ignoreByLayout ];
		background: Color transparent;
		preventMeAndChildrenMouseEvents.
	self isSelection ifTrue: [ self zIndex: 2 ].
	springLine := self newSpringLine.
	firstAnchorMarker := self newAnchorMarker.
	secondAnchorMarker := self newAnchorMarker.
	restMarker := self newRestMarker.
	self
		addChild: springLine;
		addChild: firstAnchorMarker;
		addChild: secondAnchorMarker;
		addChild: restMarker.
	self update
]

{ #category : 'private - building' }
CFPhysicsSpringVisual >> newSpringLine [
	^ BlLineElement new
		fromAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		toAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		border: (BlBorder
			paint: ((self isSelection ifTrue: [ Color red ] ifFalse: [ Color blue ]) alpha: (self isSelection ifTrue: [ 0.9 ] ifFalse: [ 0.65 ]))
			width: (self isSelection ifTrue: [ 3 ] ifFalse: [ 1 ]));
		constraintsDo: [ :c | c ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		yourself
]

{ #category : 'private - building' }
CFPhysicsSpringVisual >> newAnchorMarker [
	| diameter |
	diameter := self isSelection ifTrue: [ 8 ] ifFalse: [ 6 ].
	^ BlElement new
		geometry: BlCircleGeometry new;
		size: diameter @ diameter;
		background: ((self isSelection ifTrue: [ Color red ] ifFalse: [ Color blue ]) alpha: (self isSelection ifTrue: [ 0.9 ] ifFalse: [ 0.75 ]));
		constraintsDo: [ :c | c ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		yourself
]

{ #category : 'private - building' }
CFPhysicsSpringVisual >> newRestMarker [
	| marker side |
	side := self isSelection ifTrue: [ 9 ] ifFalse: [ 7 ].
	marker := BlElement new
		size: side @ side;
		background: Color transparent;
		border: (BlBorder
			paint: ((self isSelection ifTrue: [ Color red ] ifFalse: [ Color blue ]) alpha: (self isSelection ifTrue: [ 0.95 ] ifFalse: [ 0.8 ]))
			width: (self isSelection ifTrue: [ 2 ] ifFalse: [ 1 ]));
		constraintsDo: [ :c | c ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		yourself.
	marker transformDo: [ :aTransform |
		aTransform
			centerOrigin;
			rotateBy: 45 ].
	^ marker
]

{ #category : 'installing' }
CFPhysicsSpringVisual >> addTo: aParentElement [
	aParentElement addChild: self.
	^ self
]

{ #category : 'updating' }
CFPhysicsSpringVisual >> update [
	| worldPoints displacement distance direction resolvedRestLength |
	worldPoints := spring endpointPair worldPoints.
	firstPoint := context overlayPointFromWorld: worldPoints first.
	secondPoint := context overlayPointFromWorld: worldPoints second.
	displacement := worldPoints second - worldPoints first.
	distance := displacement r.
	direction := distance isZero
		ifTrue: [ 0 @ 0 ]
		ifFalse: [ displacement / distance ].
	resolvedRestLength := spring restLength value asFloat max: 0.0.
	restPoint := context overlayPointFromWorld: worldPoints first + (direction * resolvedRestLength).
	self
		relocate: 0 @ 0;
		size: context overlay root extent.
	springLine
		fromAnchor: (BlAbsolutePositionAnchor position: firstPoint);
		toAnchor: (BlAbsolutePositionAnchor position: secondPoint).
	self relocateMarker: firstAnchorMarker centreAt: firstPoint.
	self relocateMarker: secondAnchorMarker centreAt: secondPoint.
	self relocateMarker: restMarker centreAt: restPoint.
	^ self
]

{ #category : 'private - updating' }
CFPhysicsSpringVisual >> relocateMarker: anElement centreAt: aPoint [
	anElement relocate: aPoint - (anElement extent / 2.0)
]

{ #category : 'removing' }
CFPhysicsSpringVisual >> remove [
	self hasParent ifTrue: [ self removeFromParent ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsSpringVisual >> release [
	self remove.
	^ self
]

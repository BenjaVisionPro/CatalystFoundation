"I render one Physics body inside an overlay. I use the body's displayed geometry for either diagnostic or selection presentation without participating in the simulation."
Class {
	#name : 'CFPhysicsBodyVisual',
	#superclass : 'BlElement',
	#instVars : [ 'body', 'context', 'listener', 'presentationRole', 'sourceGeometry', 'sourceExtent', 'sensorBorder', 'solidBorder' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsBodyVisual class >> diagnosticOn: aBody context: aContext [
	^ self new
		body: aBody;
		context: aContext;
		presentationRole: #diagnostic;
		initializeVisual;
		yourself
]

{ #category : 'instance creation' }
CFPhysicsBodyVisual class >> selectionOn: aBody context: aContext [
	^ self new
		body: aBody;
		context: aContext;
		presentationRole: #selection;
		initializeVisual;
		yourself
]

{ #category : 'accessing' }
CFPhysicsBodyVisual >> body [ ^ body ]

{ #category : 'accessing' }
CFPhysicsBodyVisual >> body: aBody [ body := aBody ]

{ #category : 'accessing' }
CFPhysicsBodyVisual >> context: aContext [ context := aContext ]

{ #category : 'accessing' }
CFPhysicsBodyVisual >> presentationRole [ ^ presentationRole ]

{ #category : 'accessing' }
CFPhysicsBodyVisual >> presentationRole: aSymbol [ presentationRole := aSymbol ]

{ #category : 'testing' }
CFPhysicsBodyVisual >> isDiagnostic [ ^ presentationRole = #diagnostic ]

{ #category : 'testing' }
CFPhysicsBodyVisual >> isSelection [ ^ presentationRole = #selection ]

{ #category : 'testing' }
CFPhysicsBodyVisual >> matchesSelection: anObject [
	^ self isSelection and: [ body == anObject ]
]

{ #category : 'testing' }
CFPhysicsBodyVisual >> springForEventTarget: anElement [
	^ nil
]

{ #category : 'initialization' }
CFPhysicsBodyVisual >> initializeVisual [
	self
		constraintsDo: [ :c | c ignoreByLayout ];
		background: Color transparent;
		preventMeAndChildrenMouseEvents.
	self isSelection
		ifTrue: [
			self
				border: (BlBorder paint: (Color red alpha: 0.9) width: 3);
				zIndex: 2 ]
		ifFalse: [
			sensorBorder := BlBorder paint: (Color orange alpha: 0.65) width: 1.
			solidBorder := BlBorder paint: (Color blue alpha: 0.65) width: 1 ].
	listener := CFPhysicsBodyVisualListener for: self.
	body shapeState element addEventHandler: listener.
	self update
]

{ #category : 'installing' }
CFPhysicsBodyVisual >> addTo: aParentElement [
	aParentElement addChild: self.
	^ self
]

{ #category : 'updating' }
CFPhysicsBodyVisual >> update [
	self synchroniseGeometryAndExtent.
	self updatePresentation.
	^ self
]

{ #category : 'private - updating' }
CFPhysicsBodyVisual >> synchroniseGeometryAndExtent [
	| source currentGeometry currentExtent |
	source := body shapeState element.
	currentGeometry := source geometry.
	currentExtent := source extent.
	(sourceGeometry == currentGeometry and: [ sourceExtent = currentExtent ])
		ifTrue: [ ^ self ].
	sourceGeometry := currentGeometry.
	sourceExtent := currentExtent.
	self
		geometry: currentGeometry copy;
		size: currentExtent.
	^ self
]

{ #category : 'updating' }
CFPhysicsBodyVisual >> updatePresentation [
	| source currentExtent origin xAxis yAxis xVector yVector scale rotation |
	source := body shapeState element.
	currentExtent := source extent.
	(sourceGeometry ~~ source geometry or: [ sourceExtent ~= currentExtent ])
		ifTrue: [ self synchroniseGeometryAndExtent ].
	origin := context overlayPoint: 0 @ 0 from: source.
	xAxis := context overlayPoint: currentExtent x @ 0 from: source.
	yAxis := context overlayPoint: 0 @ currentExtent y from: source.
	xVector := xAxis - origin.
	yVector := yAxis - origin.
	scale :=
		(currentExtent x isZero
			ifTrue: [ 1.0 ]
			ifFalse: [ xVector r / currentExtent x ])
		@
		(currentExtent y isZero
			ifTrue: [ 1.0 ]
			ifFalse: [ yVector r / currentExtent y ]).
	rotation := xVector theta radiansToDegrees.
	self
		relocate: origin;
		transformDo: [ :aTransform |
			aTransform
				topLeftOrigin;
				scaleBy: scale;
				rotateBy: rotation ].
	self updateBorder.
	^ self
]

{ #category : 'private - styling' }
CFPhysicsBodyVisual >> updateBorder [
	self isSelection ifTrue: [ ^ self ].
	self border: (body isSensor ifTrue: [ sensorBorder ] ifFalse: [ solidBorder ]).
	^ self
]

{ #category : 'updating' }
CFPhysicsBodyVisual >> refreshOverlay [ context overlay refresh ]

{ #category : 'removing' }
CFPhysicsBodyVisual >> remove [
	self hasParent ifTrue: [ self removeFromParent ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsBodyVisual >> release [
	listener ifNotNil: [ body shapeState element removeEventHandler: listener ].
	self remove.
	^ self
]

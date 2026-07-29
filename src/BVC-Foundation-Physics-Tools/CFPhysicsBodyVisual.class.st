Class {
	#name : 'CFPhysicsBodyVisual',
	#superclass : 'BlElement',
	#instVars : [ 'body', 'context', 'listener', 'presentationRole' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
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

{ #category : 'initialization' }
CFPhysicsBodyVisual >> initializeVisual [
	self
		constraintsDo: [ :c | c ignoreByLayout ];
		background: Color transparent;
		preventMeAndChildrenMouseEvents.
	self isSelection ifTrue: [ self zIndex: 2 ].
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
	self updateBorder
]

{ #category : 'private - styling' }
CFPhysicsBodyVisual >> updateBorder [
	self isSelection
		ifTrue: [ self border: (BlBorder paint: (Color red alpha: 0.9) width: 3) ]
		ifFalse: [ self border: (BlBorder
			paint: ((body isSensor ifTrue: [ Color orange ] ifFalse: [ Color blue ]) alpha: 0.65)
			width: 1) ].
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


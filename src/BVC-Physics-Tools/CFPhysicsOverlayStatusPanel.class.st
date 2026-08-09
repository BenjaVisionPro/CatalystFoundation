"I present compact runtime status and processing controls for one Physics overlay. I sample delivered Motion frames and committed Physics steps without enabling telemetry."
Class {
	#name : 'CFPhysicsOverlayStatusPanel',
	#superclass : 'Object',
	#instVars : [ 'overlay', 'world', 'host', 'element', 'worldButton', 'motionLabel', 'physicsLabel', 'modeButton', 'sampleTask', 'lastSampleTime', 'lastFrameId', 'lastStepNumber' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsOverlayStatusPanel class >> on: anOverlay [
	^ self new
		overlay: anOverlay;
		world: anOverlay world;
		host: anOverlay host;
		initializePanel;
		yourself
]

{ #category : 'private - initialization' }
CFPhysicsOverlayStatusPanel >> overlay: anOverlay [ overlay := anOverlay ]

{ #category : 'private - initialization' }
CFPhysicsOverlayStatusPanel >> world: aWorld [ world := aWorld ]

{ #category : 'private - initialization' }
CFPhysicsOverlayStatusPanel >> host: anElement [ host := anElement ]

{ #category : 'accessing' }
CFPhysicsOverlayStatusPanel >> element [ ^ element ]

{ #category : 'accessing' }
CFPhysicsOverlayStatusPanel >> worldButton [ ^ worldButton ]

{ #category : 'accessing' }
CFPhysicsOverlayStatusPanel >> motionLabel [ ^ motionLabel ]

{ #category : 'accessing' }
CFPhysicsOverlayStatusPanel >> physicsLabel [ ^ physicsLabel ]

{ #category : 'accessing' }
CFPhysicsOverlayStatusPanel >> modeButton [ ^ modeButton ]

{ #category : 'initialization' }
CFPhysicsOverlayStatusPanel >> initializePanel [
	element := BrHorizontalPane new
		id: #cfPhysicsOverlayStatusPanel;
		fitContent;
		cellSpacing: 8;
		padding: (BlInsets all: 4);
		background: (Color black alpha: 0.08);
		border: (BlBorder paint: (Color black alpha: 0.12) width: 1);
		effect: (BlBlurBelowEffect radius: 14);
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 12));
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignTop ];
		margin: (BlInsets top: 14 right: 14);
		yourself.
	worldButton := BrButton new
		id: #cfPhysicsWorldInspectorButton;
		aptitude: BrGlamorousButtonWithIconCircularAptitude;
		icon: ([ (FontAwesomeIcons defaultStyle icon: #atom) size: 22 @ 22 ] asStencil);
		label: 'Inspect Physics world';
		size: 34 @ 34;
		action: [ :aButton | aButton phlow spawnObject: world ];
		yourself.
	motionLabel := self newStatLabelWithId: #cfPhysicsOverlayMotionFps text: 'Motion 0 fps'.
	physicsLabel := self newStatLabelWithId: #cfPhysicsOverlayPhysicsFps text: 'Physics 0 fps'.
	modeButton := BrButton new
		id: #cfPhysicsOverlayProcessingModeButton;
		aptitude: BrGlamorousButtonWithLabelAptitude;
		label: '';
		vExact: 34;
		action: [ self toggleProcessingMode ];
		yourself.
	element
		addChild: worldButton;
		addChild: motionLabel;
		addChild: physicsLabel;
		addChild: modeButton.
	self refreshMode.
	self startSampling
]

{ #category : 'private - building' }
CFPhysicsOverlayStatusPanel >> newStatLabelWithId: anId text: aString [
	^ BrLabel new
		id: anId;
		vExact: 34;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.72));
		text: aString;
		yourself
]

{ #category : 'private - sampling' }
CFPhysicsOverlayStatusPanel >> startSampling [
	lastSampleTime := nil.
	lastFrameId := nil.
	lastStepNumber := nil.
	sampleTask := BlRepeatedTaskAction new
		delay: 500 milliSeconds;
		action: [ :aTask | self sampleAt: aTask time now ];
		yourself.
	element enqueueTask: sampleTask
]

{ #category : 'private - sampling' }
CFPhysicsOverlayStatusPanel >> sampleAt: now [
	| frameId stepNumber elapsedMilliseconds motionFps physicsFps |
	(host isAttachedToSceneGraph and: [ world isStepping ])
		ifTrue: [ frameId := host space frame id ]
		ifFalse: [ frameId := nil ].
	stepNumber := world stepNumber.
	(lastSampleTime isNil or: [ lastFrameId isNil or: [ frameId isNil ] ]) ifTrue: [
		lastSampleTime := now.
		lastFrameId := frameId.
		lastStepNumber := stepNumber.
		motionLabel text: 'Motion 0 fps'.
		physicsLabel text: 'Physics 0 fps'.
		self refreshMode.
		^ self ].
	elapsedMilliseconds := (now - lastSampleTime) asMilliSeconds.
	elapsedMilliseconds <= 0 ifTrue: [ ^ self ].
	motionFps := ((frameId - lastFrameId) * 1000.0 / elapsedMilliseconds) rounded.
	physicsFps := ((stepNumber - lastStepNumber) * 1000.0 / elapsedMilliseconds) rounded.
	motionLabel text: 'Motion ', motionFps asString, ' fps'.
	physicsLabel text: 'Physics ', physicsFps asString, ' fps'.
	lastSampleTime := now.
	lastFrameId := frameId.
	lastStepNumber := stepNumber.
	self refreshMode
]

{ #category : 'private - updating' }
CFPhysicsOverlayStatusPanel >> refreshMode [
	modeButton label: (world backgroundStepping ifTrue: [ 'BG' ] ifFalse: [ 'FG' ])
]

{ #category : 'private - actions' }
CFPhysicsOverlayStatusPanel >> toggleProcessingMode [
	world backgroundStepping: world backgroundStepping not.
	self refreshMode.
	^ self
]

{ #category : 'controlling' }
CFPhysicsOverlayStatusPanel >> release [
	sampleTask ifNotNil: #stop.
	element ifNotNil: [ element hasParent ifTrue: [ element removeFromParent ] ]
]

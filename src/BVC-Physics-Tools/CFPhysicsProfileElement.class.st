"I present one Physics profile with shared recording controls and Pipeline and Health tabs."
Class {
	#name : 'CFPhysicsProfileElement',
	#superclass : 'BrVerticalPane',
	#instVars : [ 'world', 'startedRecording', 'statusLabel', 'tabs', 'pipeline', 'health' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsProfileElement class >> world: aWorld [
	^ self new
		world: aWorld;
		build;
		yourself
]

{ #category : 'initialization' }
CFPhysicsProfileElement >> initialize [
	super initialize.
	startedRecording := false.
	self
		hMatchParent;
		vMatchParent;
		cellSpacing: 6;
		padding: (BlInsets all: 8)
]

{ #category : 'accessing' }
CFPhysicsProfileElement >> world: aWorld [
	world := aWorld
]

{ #category : 'building' }
CFPhysicsProfileElement >> build [
	self removeChildren.
	self addChild: self buildControls.
	tabs := self buildTabs.
	self addChild: tabs.
	self updateStatus
]

{ #category : 'private - building' }
CFPhysicsProfileElement >> buildControls [
	| row startButton stopButton collectButton |
	row := BrHorizontalPane new
		hMatchParent;
		vExact: 32;
		cellSpacing: 6;
		yourself.
	startButton := BrButton new
		aptitude: BrGlamorousButtonWithIconAndLabelAptitude new;
		icon: BrGlamorousVectorIcons play;
		label: 'Start';
		action: [ self startProfiling ];
		yourself.
	stopButton := BrButton new
		aptitude: BrGlamorousButtonWithIconAndLabelAptitude new;
		icon: BrGlamorousVectorIcons stop;
		label: 'Stop';
		action: [ self stopProfiling ];
		yourself.
	collectButton := BrButton new
		aptitude: BrGlamorousButtonWithIconAndLabelAptitude new;
		icon: BrGlamorousVectorIcons refresh;
		label: 'Collect';
		action: [ health ifNotNil: [ health collectRetainedNow ] ];
		yourself.
	statusLabel := BrLabel new
		hMatchParent;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.65));
		yourself.
	row
		addChild: startButton;
		addChild: stopButton;
		addChild: collectButton;
		addChild: statusLabel.
	^ row
]

{ #category : 'private - building' }
CFPhysicsProfileElement >> buildTabs [
	pipeline := CFPhysicsTelemetryPipelineElement world: world.
	health := CFPhysicsProfileHealthElement world: world.
	^ BrTabGroup new
		hMatchParent;
		vMatchParent;
		aptitude: BrGlamorousTabGroupAptitude new;
		addTab: (BrTab new
			aptitude: BrGlamorousTabAptitude new;
			label: 'Pipeline';
			stencil: [ pipeline ]);
		addTab: (BrTab new
			aptitude: BrGlamorousTabAptitude new;
			label: 'Health';
			stencil: [ health ]);
		yourself
]

{ #category : 'actions' }
CFPhysicsProfileElement >> startProfiling [
	world resetTelemetry.
	world telemetryEnabled: true.
	health startProfiling.
	startedRecording := true.
	self updateStatus
]

{ #category : 'actions' }
CFPhysicsProfileElement >> stopProfiling [
	world telemetryEnabled: false.
	health stopProfiling.
	startedRecording := false.
	self updateStatus
]

{ #category : 'private - updating' }
CFPhysicsProfileElement >> updateStatus [
	statusLabel ifNil: [ ^ self ].
	statusLabel text: (world telemetryEnabled
		ifTrue: [ 'Recording' ]
		ifFalse: [ 'Stopped' ])
]

{ #category : 'hooks - scene graph' }
CFPhysicsProfileElement >> onRemovedFromSceneGraph [
	startedRecording ifTrue: [ world telemetryEnabled: false ].
	health ifNotNil: [ health stopProfiling ].
	super onRemovedFromSceneGraph
]

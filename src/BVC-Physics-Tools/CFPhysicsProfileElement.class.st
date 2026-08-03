"I present one Physics profile with shared recording controls and Pipeline and Health tabs."
Class {
	#name : 'CFPhysicsProfileElement',
	#superclass : 'BrVerticalPane',
	#instVars : [ 'world', 'startedRecording', 'recordingStartedMilliseconds', 'statusLabel', 'tabs', 'pipeline', 'health', 'telemetryUpdatesStream' ],
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
	recordingStartedMilliseconds := nil.
	self
		hMatchParent;
		vMatchParent;
		cellSpacing: 6;
		padding: (BlInsets all: 8)
]

{ #category : 'accessing' }
CFPhysicsProfileElement >> world: aWorld [
	world := aWorld.
	telemetryUpdatesStream := CFPhysicsTelemetryStream on: world.
	self withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anElement :aSink |
				aSink peek ifSome: [ anElement updateStatus ] ];
			forwardStream: telemetryUpdatesStream ]
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
	recordingStartedMilliseconds := Time millisecondClockValue.
	startedRecording := true.
	self updateStatus
]

{ #category : 'actions' }
CFPhysicsProfileElement >> stopProfiling [
	world telemetryEnabled: false.
	health stopProfiling.
	startedRecording := false.
	recordingStartedMilliseconds := nil.
	recordingStartedMilliseconds := nil.
	self updateStatus
]

{ #category : 'private - updating' }
CFPhysicsProfileElement >> updateStatus [
	statusLabel ifNil: [ ^ self ].
	statusLabel text: (world telemetryEnabled
		ifTrue: [ 'Recording ', self recordingElapsedString ]
		ifFalse: [ 'Stopped' ])
]

{ #category : 'private - updating' }
CFPhysicsProfileElement >> recordingElapsedString [
	| elapsedSeconds hours minutes seconds |
	recordingStartedMilliseconds ifNil: [ ^ '00:00:00' ].
	elapsedSeconds := (Time millisecondClockValue - recordingStartedMilliseconds) // 1000.
	hours := elapsedSeconds // 3600.
	minutes := (elapsedSeconds \ 3600) // 60.
	seconds := elapsedSeconds \ 60.
	^ String streamContents: [ :stream |
		stream
			nextPutAll: (hours printString padded: #left to: 2 with: $0);
			nextPut: $:;
			nextPutAll: (minutes printString padded: #left to: 2 with: $0);
			nextPut: $:;
			nextPutAll: (seconds printString padded: #left to: 2 with: $0) ]
]

{ #category : 'hooks - scene graph' }
CFPhysicsProfileElement >> onRemovedFromSceneGraph [
	startedRecording ifTrue: [ world telemetryEnabled: false ].
	health ifNotNil: [ health stopProfiling ].
	super onRemovedFromSceneGraph
]

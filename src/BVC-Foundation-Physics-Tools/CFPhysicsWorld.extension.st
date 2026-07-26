Extension { #name : 'CFPhysicsWorld' }

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsWorld >> gtTelemetryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Telemetry';
		priority: 20;
		items: [ self telemetryRecordings reversed ];
		column: 'Kind' text: [ :signal | signal physicsData at: #kind ifAbsent: [ #unknown ] ];
		column: 'Step' text: [ :signal | signal physicsData at: #stepNumber ifAbsent: [ '' ] ];
		column: 'Duration (ms)' text: [ :signal | signal duration / 1000.0 ];
		column: 'Bodies' text: [ :signal | signal physicsData at: #bodyCount ifAbsent: [ '' ] ];
		send: [ :signal | signal ];
		actionButtonIcon: BrGlamorousVectorIcons play
			label: 'Start recording'
			tooltip: 'Start recording Physics and Motion telemetry'
			action: [ :aButton :aTab |
				self telemetryEnabled: true.
				aTab viewContentElement phlow update ];
		actionButtonIcon: BrGlamorousVectorIcons stop
			label: 'Stop recording'
			tooltip: 'Stop recording telemetry and retain the recorded results'
			action: [ :aButton :aTab |
				self telemetryEnabled: false.
				aTab viewContentElement phlow update ];
		actionButtonIcon: BrGlamorousVectorIcons bin
			label: 'Clear recordings'
			tooltip: 'Clear all retained telemetry recordings'
			action: [ :aButton :aTab |
				self resetTelemetry.
				aTab viewContentElement phlow update ];
		actionUpdateButtonTooltip: 'Refresh recordings'
]

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsWorld >> gtLatestTelemetryTreeFor: aView [
	<gtView>
	| recording |
	recording := self latestTelemetryRecording.
	recording ifNil: [ ^ aView empty ].
	^ aView columnedTree
		title: 'Latest telemetry';
		priority: 21;
		items: [ { recording ping } ];
		children: [ :ping | ping tasks ];
		column: 'Span' text: #name;
		column: 'Duration (ms)' text: [ :ping | ping durationInMilliseconds ];
		column: 'GC (ms)' text: [ :ping | ping gcDurationInMilliseconds ];
		send: [ :ping | ping ];
		actionUpdateButton
]

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsWorld >> gtTelemetryStatisticsFor: aView [
	<gtView>
	^ aView explicit
		title: 'Step statistics';
		priority: 21;
		stencil: [ CFPhysicsTelemetryPipelineElement world: self ];
		actionUpdateButtonTooltip: 'Refresh step statistics'
]

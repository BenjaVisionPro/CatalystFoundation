Extension { #name : 'CFPhysicsWorld' }

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsWorld >> gtLivePhysicsFor: aView [
	<gtView>
	owner ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Live Physics';
		priority: 1;
		object: [ owner ];
		view: #gtLiveFor:
]

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsWorld >> gtPerformanceFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Performance';
		priority: 2;
		items: [ self telemetry metrics ];
		column: 'Metric' text: #name;
		column: 'Latest' text: [ :metric |
			self telemetry formattedValueOf: metric value: metric latest ];
		column: 'Average' text: [ :metric |
			self telemetry formattedValueOf: metric value: metric average ];
		column: 'P95' text: [ :metric |
			self telemetry formattedValueOf: metric value: metric p95 ];
		column: 'Maximum' text: [ :metric |
			self telemetry formattedValueOf: metric value: metric maximum ];
		column: 'Frame share' text: [ :metric |
			(self telemetry latestFrameShareOf: metric)
				ifNil: [ '' ]
				ifNotNil: [ :share | self telemetry formattedPercent: share ] ];
		send: [ :metric | metric ];
		actionUpdateButton
]

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsWorld >> gtStageTimingsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Stage timings';
		priority: 3;
		items: [ self telemetry stageMetrics ];
		column: 'Stage' text: #name;
		column: 'Latest (ms)' text: [ :metric |
			self telemetry formattedMilliseconds: metric latest ];
		column: 'Average (ms)' text: [ :metric |
			self telemetry formattedMilliseconds: metric average ];
		column: 'P95 (ms)' text: [ :metric |
			self telemetry formattedMilliseconds: metric p95 ];
		column: 'Maximum (ms)' text: [ :metric |
			self telemetry formattedMilliseconds: metric maximum ];
		column: 'Pipeline share' text: [ :metric |
			self telemetry formattedPercent: (self telemetry latestPipelineShareOf: metric) ];
		send: [ :metric | metric ];
		actionUpdateButton
]

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsWorld >> gtHotspotsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Hotspots';
		priority: 4;
		items: [ self telemetry hotspots ];
		column: 'Stage' text: #name;
		column: 'Average (ms)' text: [ :metric |
			self telemetry formattedMilliseconds: metric average ];
		column: 'P95 (ms)' text: [ :metric |
			self telemetry formattedMilliseconds: metric p95 ];
		column: 'Maximum (ms)' text: [ :metric |
			self telemetry formattedMilliseconds: metric maximum ];
		column: 'Latest (ms)' text: [ :metric |
			self telemetry formattedMilliseconds: metric latest ];
		column: 'Latest share' text: [ :metric |
			self telemetry formattedPercent: (self telemetry latestPipelineShareOf: metric) ];
		send: [ :metric | metric ];
		actionUpdateButton
]

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsWorld >> gtFrameHistoryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Frame history';
		priority: 5;
		items: [ self telemetry samples reversed ];
		column: 'Step' text: #stepNumber;
		column: 'Total (ms)' text: [ :sample | self telemetry formattedMilliseconds: sample totalMilliseconds ];
		column: 'Pipeline (ms)' text: [ :sample | self telemetry formattedMilliseconds: sample pipelineMilliseconds ];
		column: 'Unaccounted (ms)' text: [ :sample | self telemetry formattedMilliseconds: sample unaccountedMilliseconds ];
		column: 'Bodies' text: #bodyCount;
		column: 'Active' text: #activeBodyCount;
		column: 'Contacts' text: #contactCount;
		column: 'Constraints' text: #constraintCount;
		column: 'Joints' text: #jointCount;
		send: [ :sample | sample ];
		actionUpdateButton
]

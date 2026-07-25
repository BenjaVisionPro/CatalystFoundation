Extension { #name : 'CFPhysicsWorld' }

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsWorld >> gtLivePhysicsFor: aView [
	<gtView>
	owner ifNil: [ ^ aView empty ].
	self telemetry.
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
		items: [ self telemetry performanceRows ];
		column: 'Metric' text: #key;
		column: 'Latest' text: [ :row | row value first ];
		column: 'Average' text: [ :row | row value second ];
		column: 'P95' text: [ :row | row value third ];
		column: 'Maximum' text: [ :row | row value fourth ];
		actionUpdateButton
]

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsWorld >> gtStageTimingsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Stage timings';
		priority: 3;
		items: [ self telemetry stageRows ];
		column: 'Stage' text: #key;
		column: 'Latest (ms)' text: [ :row | row value first ];
		column: 'Average (ms)' text: [ :row | row value second ];
		actionUpdateButton
]

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsWorld >> gtFrameHistoryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Frame history';
		priority: 4;
		items: [ self telemetry samples reversed ];
		column: 'Step' text: #stepNumber;
		column: 'Total (ms)' text: #totalMilliseconds;
		column: 'Pipeline (ms)' text: #pipelineMilliseconds;
		column: 'Bodies' text: #bodyCount;
		column: 'Active' text: #activeBodyCount;
		column: 'Contacts' text: #contactCount;
		column: 'Constraints' text: #constraintCount;
		column: 'Joints' text: #jointCount;
		send: [ :sample | sample ];
		actionUpdateButton
]

Extension { #name : 'CFPhysicsStageMetric' }

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsStageMetric >> gtSummaryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Summary';
		priority: 1;
		items: [ {
			'Stage' -> self stageClass.
			'Latest (ms)' -> self latest.
			'Average (ms)' -> self average.
			'Minimum (ms)' -> self minimum.
			'P95 (ms)' -> self p95.
			'Maximum (ms)' -> self maximum.
			'Samples' -> self sampleCount } ];
		column: 'Property' text: #key;
		column: 'Value' text: [ :association | association value printString ];
		send: #value
]

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsStageMetric >> gtExecutionsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Executions';
		priority: 2;
		items: [ self executions reversed ];
		column: 'Duration (ms)' text: [ :execution | execution durationMilliseconds printString ];
		column: 'Output' text: [ :execution | execution output printString ];
		send: [ :execution | execution ]
]

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsStageMetric >> gtLatestExecutionFor: aView [
	<gtView>
	self latestExecution ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Latest execution';
		priority: 3;
		object: [ self latestExecution ];
		view: #gtSummaryFor:
]

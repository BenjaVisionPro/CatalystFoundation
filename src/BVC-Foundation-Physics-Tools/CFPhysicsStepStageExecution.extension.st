Extension { #name : 'CFPhysicsStepStageExecution' }

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsStepStageExecution >> gtSummaryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Summary';
		priority: 1;
		items: [ {
			'Stage' -> self stage.
			'Duration (ms)' -> self durationMilliseconds.
			'Output' -> self output } ];
		column: 'Property' text: #key;
		column: 'Value' text: [ :association | association value printString ];
		send: #value
]

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsStepStageExecution >> gtOutputFor: aView [
	<gtView>
	self output ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Output';
		priority: 2;
		object: [ self output ];
		view: #gtLiveFor:
]

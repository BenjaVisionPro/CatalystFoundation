Extension { #name : 'CFPhysicsStepPipelineResult' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsStepPipelineResult >> gtPredictedBodiesFor: aView [
	<gtView>
	self bodyStates ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Predicted bodies';
		priority: 1;
		items: [ self bodies collect: [ :body | self bodyStates at: body ] ];
		column: 'Sequence' text: [ :state | state body sequence ];
		column: 'Body' text: [ :state | state body ];
		column: 'Start' text: [ :state | state body position ];
		column: 'Predicted end' text: [ :state |
			(state predictedTransformAfter: self step timeStep) position ];
		column: 'Velocity' text: #linearVelocity;
		column: 'Angular velocity' text: #angularVelocity;
		column: 'Swept bounds' text: [ :state |
			state predictedSweptAABBFor: self step timeStep ];
		send: [ :state | state ]
]

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsStepPipelineResult >> gtCandidatePairsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Candidate pairs';
		priority: 2;
		items: [ self pairs ];
		column: 'First sequence' text: [ :pair | pair firstBody sequence ];
		column: 'First body' text: #firstBody;
		column: 'Second sequence' text: [ :pair | pair secondBody sequence ];
		column: 'Second body' text: #secondBody;
		send: [ :pair | pair ]
]

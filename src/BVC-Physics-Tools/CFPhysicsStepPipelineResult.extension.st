Extension { #name : 'CFPhysicsStepPipelineResult' }

{ #category : '*bvc-physics-tools' }
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

{ #category : '*bvc-physics-tools' }
CFPhysicsStepPipelineResult >> gtPredictedBodiesFor: aView [
	<gtView>
	self bodyStates ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Predicted bodies';
		priority: 1;
		items: [ self bodies collect: [ :body | self bodyStates at: body ] ];
		column: 'Sequence' text: [ :state | state body sequence ];
		column: 'Body' text: [ :state | state body ];
		column: 'Start body origin' text: [ :state | state startBodyOrigin ];
		column: 'Predicted body origin' text: [ :state |
			(state predictedTransformAfter: self step timeStep) bodyOrigin ];
		column: 'Velocity' text: #linearVelocity;
		column: 'Angular velocity' text: #angularVelocity;
		column: 'Swept bounds' text: [ :state |
			state predictedSweptAABBFor: self step timeStep ];
		send: [ :state | state ]
]

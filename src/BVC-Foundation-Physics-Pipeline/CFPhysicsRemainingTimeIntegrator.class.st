Class {
	#name : 'CFPhysicsRemainingTimeIntegrator',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'integration' }
CFPhysicsRemainingTimeIntegrator >> integrateBodyStates: bodyStates after: anImpactSolveResult [
	bodyStates valuesDo: [ :state |
		state integratePositionBy: anImpactSolveResult remainingTime ].
	^ anImpactSolveResult
]

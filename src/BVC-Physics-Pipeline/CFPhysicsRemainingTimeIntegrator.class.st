Class {
	#name : 'CFPhysicsRemainingTimeIntegrator',
	#superclass : 'Object',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'integration' }
CFPhysicsRemainingTimeIntegrator >> integrateBodyStates: bodyStates after: anImpactSolveResult [
	bodyStates valuesDo: [ :state |
		state integratePositionBy: anImpactSolveResult remainingTime ].
	^ anImpactSolveResult
]

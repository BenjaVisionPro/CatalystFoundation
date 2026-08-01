"
I integrate body states through the time left after continuous impacts are solved. I completes the substep for bodies not otherwise advanced to its end.
"

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

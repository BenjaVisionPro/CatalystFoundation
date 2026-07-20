Class {
	#name : 'CFPhysicsImpactAdvancer',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'advancing' }
CFPhysicsImpactAdvancer >> advanceBodyStates: bodyStates to: aPairTimeOfImpact for: seconds [
	| elapsedTime remainingTime |
	elapsedTime := seconds * aPairTimeOfImpact fraction.
	remainingTime := seconds - elapsedTime.
	bodyStates valuesDo: [ :state |
		state integratePositionBy: elapsedTime ].
	^ CFPhysicsImpactAdvancementResult
		impact: aPairTimeOfImpact
		elapsedTime: elapsedTime
		remainingTime: remainingTime
]

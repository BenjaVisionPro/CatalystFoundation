Class {
	#name : 'CFPhysicsImpactAdvancer',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'advancing' }
CFPhysicsImpactAdvancer >> advanceBodyStates: bodyStates to: aPairTimeOfImpact for: seconds [
	^ (self
		advanceBodyStates: bodyStates
		toImpacts: { aPairTimeOfImpact }
		for: seconds) first
]

{ #category : 'advancing' }
CFPhysicsImpactAdvancer >> advanceBodyStates: bodyStates toImpacts: impacts for: seconds [
	| elapsedTime remainingTime |
	impacts ifEmpty: [ ^ #() ].
	elapsedTime := seconds * impacts first fraction.
	remainingTime := seconds - elapsedTime.
	bodyStates valuesDo: [ :state |
		state integratePositionBy: elapsedTime ].
	^ impacts collect: [ :impact |
		CFPhysicsImpactAdvancementResult
			impact: impact
			elapsedTime: elapsedTime
			remainingTime: remainingTime ]
]

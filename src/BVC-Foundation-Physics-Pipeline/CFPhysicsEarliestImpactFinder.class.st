Class {
	#name : 'CFPhysicsEarliestImpactFinder',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'finding' }
CFPhysicsEarliestImpactFinder >> earliestAmong: pairs bodyStates: bodyStates for: seconds [
	| earliest tolerance |
	tolerance := 1.0e-9.
	earliest := nil.
	pairs do: [ :pair |
		| candidate |
		candidate := self
			timeOfImpactFor: pair
			bodyStates: bodyStates
			for: seconds.
		candidate timeOfImpactResult hasImpact ifTrue: [
			(earliest isNil or: [
				(self candidate: candidate comesBefore: earliest tolerance: tolerance) ])
				ifTrue: [ earliest := candidate ] ] ].
	^ earliest
]

{ #category : 'private' }
CFPhysicsEarliestImpactFinder >> candidate: candidate comesBefore: current tolerance: tolerance [
	candidate fraction < (current fraction - tolerance) ifTrue: [ ^ true ].
	((candidate fraction - current fraction) abs <= tolerance) ifTrue: [
		^ candidate pair comesBefore: current pair ].
	^ false
]

{ #category : 'private' }
CFPhysicsEarliestImpactFinder >> timeOfImpactFor: pair bodyStates: bodyStates for: seconds [
	| firstState secondState result |
	firstState := bodyStates at: pair firstBody.
	secondState := bodyStates at: pair secondBody.
	result := CFPhysicsConservativeAdvancement
		betweenShapeState: pair firstBody shapeState
		sweep: (firstState predictedSweepFor: seconds)
		andShapeState: pair secondBody shapeState
		sweep: (secondState predictedSweepFor: seconds).
	^ CFPhysicsPairTimeOfImpact pair: pair result: result
]

{ #category : 'finding' }
CFPhysicsEarliestImpactFinder >> earliestAmong: pairs bodyStates: bodyStates for: seconds afterFraction: minimumFraction [
	| earliest tolerance |
	tolerance := 1.0e-9.
	earliest := nil.
	pairs do: [ :pair |
		| candidate |
		candidate := self
			timeOfImpactFor: pair
			bodyStates: bodyStates
			for: seconds.
		(candidate timeOfImpactResult hasImpact and: [
			candidate fraction > minimumFraction ]) ifTrue: [
			(earliest isNil or: [
				(self candidate: candidate comesBefore: earliest tolerance: tolerance) ])
				ifTrue: [ earliest := candidate ] ] ].
	^ earliest
]

{ #category : 'finding' }
CFPhysicsEarliestImpactFinder >> impactsAmong: pairs bodyStates: bodyStates for: seconds afterFraction: minimumFraction [
	| impacts |
	impacts := OrderedCollection new.
	pairs do: [ :pair |
		| candidate |
		candidate := self
			timeOfImpactFor: pair
			bodyStates: bodyStates
			for: seconds.
		(candidate timeOfImpactResult hasImpact and: [
			candidate fraction > minimumFraction ]) ifTrue: [
			impacts add: candidate ] ].
	^ impacts asArray sorted: [ :left :right |
		(self candidate: left comesBefore: right tolerance: 1.0e-9) ]
]

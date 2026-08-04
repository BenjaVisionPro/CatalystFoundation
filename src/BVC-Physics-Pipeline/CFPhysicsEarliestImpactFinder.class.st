"
I find the earliest valid time of impact among collision pairs. I order competing impacts deterministically and ignore pairs that do not produce a solved impact.
"

Class {
	#name : 'CFPhysicsEarliestImpactFinder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
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
		betweenShapeState: firstState shapeState
		sweep: (firstState predictedSweepFor: seconds)
		andShapeState: secondState shapeState
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

{ #category : 'finding' }
CFPhysicsEarliestImpactFinder >> impactsAtEarliestTimeAmong: pairs bodyStates: bodyStates for: seconds afterFraction: minimumFraction [
	| impacts earliest tolerance |
	tolerance := 1.0e-9.
	impacts := self
		impactsAmong: pairs
		bodyStates: bodyStates
		for: seconds
		afterFraction: minimumFraction.
	impacts ifEmpty: [ ^ #() ].
	earliest := impacts first.
	^ impacts select: [ :each |
		each fraction <= (earliest fraction + tolerance) ]
]


{ #category : 'finding - solved sweeps' }
CFPhysicsEarliestImpactFinder >> earliestSolvedAmong: pairs bodyStates: bodyStates afterFraction: minimumFraction [
	| candidates |
	candidates := self solvedImpactsAmong: pairs bodyStates: bodyStates afterFraction: minimumFraction.
	^ candidates ifEmpty: [ nil ] ifNotEmpty: [ candidates first ]
]

{ #category : 'finding - solved sweeps' }
CFPhysicsEarliestImpactFinder >> earliestSolvedAmong: pairs bodyStates: bodyStates afterFraction: minimumFraction linearSlop: linearSlop [
	| candidates |
	candidates := self
		solvedImpactsAmong: pairs
		bodyStates: bodyStates
		afterFraction: minimumFraction
		linearSlop: linearSlop.
	^ candidates ifEmpty: [ nil ] ifNotEmpty: [ candidates first ]
]

{ #category : 'finding - solved sweeps' }
CFPhysicsEarliestImpactFinder >> earliestSolvedAmong: pairs bodyStates: bodyStates afterFraction: minimumFraction linearSlop: linearSlop fastBody: fastBody [
	| candidates |
	candidates := self
		solvedImpactsAmong: pairs
		bodyStates: bodyStates
		afterFraction: minimumFraction
		linearSlop: linearSlop
		fastBody: fastBody.
	^ candidates ifEmpty: [ nil ] ifNotEmpty: [ candidates first ]
]

{ #category : 'finding - solved sweeps' }
CFPhysicsEarliestImpactFinder >> solvedImpactsAmong: pairs bodyStates: bodyStates afterFraction: minimumFraction [
	| impacts |
	impacts := OrderedCollection new.
	pairs do: [ :pair |
		| candidate |
		candidate := self solvedTimeOfImpactFor: pair bodyStates: bodyStates.
		(candidate timeOfImpactResult hasImpact and: [ candidate fraction > minimumFraction ]) ifTrue: [
			impacts add: candidate ] ].
	^ impacts asArray sorted: [ :left :right |
		self candidate: left comesBefore: right tolerance: 1.0e-9 ]
]

{ #category : 'finding - solved sweeps' }
CFPhysicsEarliestImpactFinder >> solvedImpactsAmong: pairs bodyStates: bodyStates afterFraction: minimumFraction linearSlop: linearSlop [
	| impacts |
	impacts := OrderedCollection new.
	pairs do: [ :pair |
		| candidate |
		candidate := self solvedTimeOfImpactFor: pair bodyStates: bodyStates linearSlop: linearSlop.
		(candidate timeOfImpactResult hasImpact and: [ candidate fraction > minimumFraction ]) ifTrue: [
			impacts add: candidate ] ].
	^ impacts asArray sorted: [ :left :right |
		self candidate: left comesBefore: right tolerance: 1.0e-9 ]
]

{ #category : 'finding - solved sweeps' }
CFPhysicsEarliestImpactFinder >> solvedImpactsAmong: pairs bodyStates: bodyStates afterFraction: minimumFraction linearSlop: linearSlop fastBody: fastBody [
	| impacts |
	impacts := OrderedCollection new.
	pairs do: [ :pair |
		| candidate |
		candidate := self
			solvedTimeOfImpactFor: pair
			bodyStates: bodyStates
			linearSlop: linearSlop
			fastBody: fastBody.
		(candidate timeOfImpactResult hasImpact and: [ candidate fraction > minimumFraction ]) ifTrue: [
			impacts add: candidate ] ].
	^ impacts asArray sorted: [ :left :right |
		self candidate: left comesBefore: right tolerance: 1.0e-9 ]
]

{ #category : 'private - solved sweeps' }
CFPhysicsEarliestImpactFinder >> solvedTimeOfImpactFor: pair bodyStates: bodyStates [
	| firstState secondState result |
	firstState := bodyStates at: pair firstBody.
	secondState := bodyStates at: pair secondBody.
	result := CFPhysicsConservativeAdvancement
		betweenShapeState: firstState shapeState
		sweep: firstState solvedSweep
		andShapeState: secondState shapeState
		sweep: secondState solvedSweep.
	^ CFPhysicsPairTimeOfImpact pair: pair result: result
]

{ #category : 'private - solved sweeps' }
CFPhysicsEarliestImpactFinder >> solvedTimeOfImpactFor: pair bodyStates: bodyStates linearSlop: linearSlop [
	| firstState secondState result |
	firstState := bodyStates at: pair firstBody.
	secondState := bodyStates at: pair secondBody.
	result := CFPhysicsBox2DTimeOfImpact
		betweenShapeState: firstState shapeState
		sweep: firstState solvedSweep
		andShapeState: secondState shapeState
		sweep: secondState solvedSweep
		linearSlop: linearSlop.
	^ CFPhysicsPairTimeOfImpact pair: pair result: result
]

{ #category : 'private - solved sweeps' }
CFPhysicsEarliestImpactFinder >> solvedTimeOfImpactFor: pair bodyStates: bodyStates linearSlop: linearSlop fastBody: fastBody [
	| firstState secondState firstShapeState secondShapeState result fastState fallbackProxy firstProxy secondProxy fallbackResult |
	firstState := bodyStates at: pair firstBody.
	secondState := bodyStates at: pair secondBody.
	firstShapeState := firstState shapeStateFor: pair firstShape.
	secondShapeState := secondState shapeStateFor: pair secondShape.
	result := (firstShapeState isSensor or: [ secondShapeState isSensor ])
		ifTrue: [
			"Swept sensors are a Catalyst event contract, not a Box2D contact constraint. Preserve crossings even when the shapes are separated again at the end of the step."
			CFPhysicsConservativeAdvancement
				betweenShapeState: firstShapeState
				sweep: firstState solvedSweep
				andShapeState: secondShapeState
				sweep: secondState solvedSweep ]
		ifFalse: [
			CFPhysicsBox2DTimeOfImpact
				betweenShapeState: firstShapeState
				sweep: firstState solvedSweep
				andShapeState: secondShapeState
				sweep: secondState solvedSweep
				linearSlop: linearSlop ].
	result fraction = 0.0 ifTrue: [
		fastState := bodyStates at: fastBody.
		fallbackProxy := CFPhysicsDistanceProxy
			points: { 0 @ 0 }
			radius: 0.25 * fastState shapeState minimumExtent.
		firstProxy := pair firstBody == fastBody
			ifTrue: [ fallbackProxy ]
			ifFalse: [ firstShapeState distanceProxy ].
		secondProxy := pair secondBody == fastBody
			ifTrue: [ fallbackProxy ]
			ifFalse: [ secondShapeState distanceProxy ].
		fallbackResult := CFPhysicsBox2DTimeOfImpact
			betweenProxy: firstProxy
			sweep: firstState solvedSweep
			andProxy: secondProxy
			sweep: secondState solvedSweep
			linearSlop: linearSlop.
		(fallbackResult hasImpact and: [ fallbackResult fraction > 0.0 ]) ifTrue: [ result := fallbackResult ] ].
	^ CFPhysicsPairTimeOfImpact pair: pair result: result
]

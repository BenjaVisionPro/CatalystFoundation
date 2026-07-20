Class {
	#name : 'CFPhysicsContinuousImpactLoop',
	#superclass : 'Object',
	#instVars : [ 'pairFinder', 'impactFinder', 'impactAdvancer', 'impactSolver', 'maximumIterations' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsContinuousImpactLoop >> initialize [
	super initialize.
	pairFinder := CFPhysicsPairFinder new.
	impactFinder := CFPhysicsEarliestImpactFinder new.
	impactAdvancer := CFPhysicsImpactAdvancer new.
	impactSolver := CFPhysicsImpactSolver new.
	maximumIterations := 8
]

{ #category : 'executing' }
CFPhysicsContinuousImpactLoop >> executeBodyStates: bodyStates step: step restitutionThreshold: restitutionThreshold [
	| impacts impactSolveResults sensorContactsByKey remainingTime tolerance iterationLimitReached |
	impacts := OrderedCollection new.
	impactSolveResults := OrderedCollection new.
	sensorContactsByKey := Dictionary new.
	remainingTime := step timeStep.
	tolerance := 1.0e-9.
	iterationLimitReached := false.
	1 to: maximumIterations do: [ :iteration |
		| pairs solidPairs sensorPairs impact advancement impactStep solveResult |
		remainingTime <= tolerance ifTrue: [
			^ self
				resultWithImpacts: impacts
				impactSolveResults: impactSolveResults
				sensorContacts: (self orderedSensorContactsFrom: sensorContactsByKey)
				bodyStates: bodyStates
				remainingTime: 0.0
				iterationLimitReached: false ].
		pairs := pairFinder
			pairsAmongStepStates: bodyStates values
			for: remainingTime.
		solidPairs := pairs reject: [ :pair |
			pair firstBody isSensor or: [ pair secondBody isSensor ] ].
		sensorPairs := pairs select: [ :pair |
			pair firstBody isSensor or: [ pair secondBody isSensor ] ].
		impact := impactFinder
			earliestAmong: solidPairs
			bodyStates: bodyStates
			for: remainingTime
			afterFraction: tolerance.
		self
			recordSensorContactsAmong: sensorPairs
			bodyStates: bodyStates
			for: remainingTime
			throughFraction: (impact ifNil: [ 1.0 ] ifNotNil: [ impact fraction ])
			into: sensorContactsByKey.
		impact ifNil: [
			bodyStates valuesDo: [ :state |
				state integratePositionBy: remainingTime ].
			^ self
				resultWithImpacts: impacts
				impactSolveResults: impactSolveResults
				sensorContacts: (self orderedSensorContactsFrom: sensorContactsByKey)
				bodyStates: bodyStates
				remainingTime: 0.0
				iterationLimitReached: false ].
		advancement := impactAdvancer
			advanceBodyStates: bodyStates
			to: impact
			for: remainingTime.
		impactStep := CFPhysicsStep
			timeStep: advancement remainingTime
			substeps: step substepCount
			contactHertz: step contactHertz
			dampingRatio: step contactDampingRatio.
		impactStep warmStartRatio: 0.0.
		solveResult := impactSolver
			solveAdvancement: advancement
			bodyStates: bodyStates
			step: impactStep
			restitutionThreshold: restitutionThreshold.
		impacts add: impact.
		impactSolveResults add: solveResult.
		remainingTime := solveResult remainingTime ].
	remainingTime > tolerance ifTrue: [ iterationLimitReached := true ].
	^ self
		resultWithImpacts: impacts
		impactSolveResults: impactSolveResults
		sensorContacts: (self orderedSensorContactsFrom: sensorContactsByKey)
		bodyStates: bodyStates
		remainingTime: remainingTime
		iterationLimitReached: iterationLimitReached
]

{ #category : 'private' }
CFPhysicsContinuousImpactLoop >> resultWithImpacts: impacts impactSolveResults: solveResults sensorContacts: sensorContacts bodyStates: bodyStates remainingTime: remainingTime iterationLimitReached: iterationLimitReached [
	^ CFPhysicsContinuousImpactLoopResult
		impacts: impacts
		impactSolveResults: solveResults
		sensorContacts: sensorContacts
		bodyStates: bodyStates
		remainingTime: remainingTime
		iterationLimitReached: iterationLimitReached
]

{ #category : 'private - sensors' }
CFPhysicsContinuousImpactLoop >> recordSensorContactsAmong: pairs bodyStates: bodyStates for: seconds throughFraction: maximumFraction into: contactsByKey [
	| tolerance |
	tolerance := 1.0e-9.
	(impactFinder
		impactsAmong: pairs
		bodyStates: bodyStates
		for: seconds
		afterFraction: tolerance) do: [ :impact |
		impact fraction <= (maximumFraction + tolerance) ifTrue: [
			| contact |
			contact := self
				contactForSensorImpact: impact
				bodyStates: bodyStates
				for: seconds.
			contact ifNotNil: [
				contactsByKey at: contact key ifAbsentPut: [ contact ] ] ] ]
]

{ #category : 'private - sensors' }
CFPhysicsContinuousImpactLoop >> contactForSensorImpact: impact bodyStates: bodyStates for: seconds [
	| pair firstSweep secondSweep manifold |
	pair := impact pair.
	firstSweep := (bodyStates at: pair firstBody) predictedSweepFor: seconds.
	secondSweep := (bodyStates at: pair secondBody) predictedSweepFor: seconds.
	manifold := CFPhysicsCollision
		manifoldBetweenShapeState: pair firstBody shapeState
		transform: (firstSweep transformAt: impact fraction)
		andShapeState: pair secondBody shapeState
		transform: (secondSweep transformAt: impact fraction).
	manifold ifNil: [ ^ nil ].
	^ CFPhysicsContact pair: pair manifold: manifold
]

{ #category : 'private - sensors' }
CFPhysicsContinuousImpactLoop >> orderedSensorContactsFrom: contactsByKey [
	^ contactsByKey values asArray sorted: [ :left :right |
		left pair comesBefore: right pair ]
]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoop >> maximumIterations [ ^ maximumIterations ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoop >> maximumIterations: anInteger [ maximumIterations := anInteger ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoop >> pairFinder [ ^ pairFinder ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoop >> pairFinder: anObject [ pairFinder := anObject ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoop >> impactFinder [ ^ impactFinder ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoop >> impactFinder: anObject [ impactFinder := anObject ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoop >> impactAdvancer [ ^ impactAdvancer ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoop >> impactAdvancer: anObject [ impactAdvancer := anObject ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoop >> impactSolver [ ^ impactSolver ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoop >> impactSolver: anObject [ impactSolver := anObject ]

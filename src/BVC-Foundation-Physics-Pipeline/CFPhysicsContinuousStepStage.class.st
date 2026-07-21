Class {
	#name : 'CFPhysicsContinuousStepStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'loop', 'impactFinder', 'componentBuilder' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsContinuousStepStage >> initialize [
	super initialize.
	loop := CFPhysicsContinuousImpactLoop new.
	impactFinder := CFPhysicsEarliestImpactFinder new.
	componentBuilder := CFPhysicsContinuousComponentBuilder new
]

{ #category : 'executing' }
CFPhysicsContinuousStepStage >> executeOn: aStepResult [
	| continuousResult solidPairs sensorPairs tolerance initialImpact continuousBodyStates continuousBodies continuousJoints |
	tolerance := 1.0e-9.
	solidPairs := aStepResult pairs reject: [ :pair |
		pair firstBody isSensor or: [ pair secondBody isSensor ] ].
	sensorPairs := aStepResult pairs select: [ :pair |
		pair firstBody isSensor or: [ pair secondBody isSensor ] ].
	initialImpact := impactFinder
		earliestAmong: solidPairs
		bodyStates: aStepResult bodyStates
		for: aStepResult step timeStep
		afterFraction: tolerance.
	initialImpact ifNil: [
		aStepResult continuousSensorContacts: (self
			sensorContactsAmong: sensorPairs
			bodyStates: aStepResult bodyStates
			for: aStepResult step timeStep
			afterFraction: tolerance).
		aStepResult continuousStepResult: nil.
		^ nil ].
	continuousBodyStates := componentBuilder
		bodyStatesForImpact: initialImpact
		from: aStepResult bodyStates
		joints: aStepResult joints.
	continuousBodies := continuousBodyStates keys.
	continuousJoints := componentBuilder
		jointsForBodies: continuousBodies
		from: aStepResult joints.
	continuousResult := loop
		executeBodyStates: continuousBodyStates
		joints: continuousJoints
		step: aStepResult step
		restitutionThreshold: aStepResult restitutionThreshold.
	aStepResult continuousSensorContacts: (self
		sensorContactsAmong: sensorPairs
		bodyStates: aStepResult bodyStates
		for: aStepResult step timeStep
		afterFraction: tolerance
		throughFraction: initialImpact fraction).
	continuousResult hasImpacts ifTrue: [
		self commitBodyStatesInOrder: continuousBodyStates.
		self recaptureBodyStatesAndPairsOn: aStepResult ].
	aStepResult continuousStepResult: continuousResult.
	^ continuousResult
]

{ #category : 'private - committing' }
CFPhysicsContinuousStepStage >> commitBodyStatesInOrder: bodyStates [
	(bodyStates values sorted: [ :first :second |
		first body sequence < second body sequence ]) do: #commit
]

{ #category : 'private - capturing' }
CFPhysicsContinuousStepStage >> recaptureBodyStatesAndPairsOn: aStepResult [
	| states |
	states := IdentityDictionary new.
	aStepResult bodies do: [ :body |
		states at: body put: (CFPhysicsBodyStepState on: body) ].
	aStepResult bodyStates: states.
	aStepResult pairs: (CFPhysicsPairFinder new
		pairsAmongStepStates: states values
		for: 0.0)
]

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> loop [ ^ loop ]

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> loop: anObject [ loop := anObject ]

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> impactFinder [ ^ impactFinder ]

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> impactFinder: anObject [ impactFinder := anObject ]

{ #category : 'private - sensors' }
CFPhysicsContinuousStepStage >> sensorContactsAmong: pairs bodyStates: bodyStates for: seconds afterFraction: minimumFraction [
	^ ((impactFinder
		impactsAmong: pairs
		bodyStates: bodyStates
		for: seconds
		afterFraction: minimumFraction) collect: [ :impact |
		self contactForSensorImpact: impact bodyStates: bodyStates for: seconds ])
		reject: #isNil
]


{ #category : 'private - sensors' }
CFPhysicsContinuousStepStage >> sensorContactsAmong: pairs bodyStates: bodyStates for: seconds afterFraction: minimumFraction throughFraction: maximumFraction [
	^ ((impactFinder
		impactsAmong: pairs
		bodyStates: bodyStates
		for: seconds
		afterFraction: minimumFraction) select: [ :impact |
		impact fraction <= (maximumFraction + 1.0e-9) ]) collect: [ :impact |
		self contactForSensorImpact: impact bodyStates: bodyStates for: seconds ] thenReject: #isNil
]

{ #category : 'private - sensors' }
CFPhysicsContinuousStepStage >> contactForSensorImpact: impact bodyStates: bodyStates for: seconds [
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

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> componentBuilder [ ^ componentBuilder ]

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> componentBuilder: anObject [ componentBuilder := anObject ]

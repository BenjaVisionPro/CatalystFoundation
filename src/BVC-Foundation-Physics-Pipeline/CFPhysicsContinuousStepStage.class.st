Class {
	#name : 'CFPhysicsContinuousStepStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'loop', 'impactFinder' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsContinuousStepStage >> initialize [
	super initialize.
	loop := CFPhysicsContinuousImpactLoop new.
	impactFinder := CFPhysicsEarliestImpactFinder new
]

{ #category : 'executing' }
CFPhysicsContinuousStepStage >> executeOn: aStepResult [
	| continuousResult solidPairs sensorPairs tolerance initialImpact sensorContacts |
	tolerance := 1.0e-9.
	solidPairs := aStepResult pairs reject: [ :pair |
		pair firstBody isSensor or: [ pair secondBody isSensor ] ].
	sensorPairs := aStepResult pairs select: [ :pair |
		pair firstBody isSensor or: [ pair secondBody isSensor ] ].
	sensorContacts := self
		sensorContactsAmong: sensorPairs
		bodyStates: aStepResult bodyStates
		for: aStepResult step timeStep
		afterFraction: tolerance.
	aStepResult continuousSensorContacts: sensorContacts.
	initialImpact := impactFinder
		earliestAmong: solidPairs
		bodyStates: aStepResult bodyStates
		for: aStepResult step timeStep
		afterFraction: tolerance.
	initialImpact ifNil: [
		aStepResult continuousStepResult: nil.
		^ nil ].
	continuousResult := loop
		executeBodyStates: aStepResult bodyStates
		step: aStepResult step
		restitutionThreshold: aStepResult restitutionThreshold.
	continuousResult hasImpacts ifTrue: [
		self commitBodyStatesInOrder: aStepResult bodyStates ].
	aStepResult continuousStepResult: continuousResult.
	^ continuousResult
]

{ #category : 'private - committing' }
CFPhysicsContinuousStepStage >> commitBodyStatesInOrder: bodyStates [
	(bodyStates values sorted: [ :first :second |
		first body sequence < second body sequence ]) do: #commit
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

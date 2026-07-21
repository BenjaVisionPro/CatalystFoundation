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
	| solidPairs sensorPairs tolerance remainingSolidPairs initialImpact continuousBodyStates continuousBodies continuousJoints componentResult impacts impactSolveResults completedBodies completedDynamicBodies sensorContactsByKey iterationLimitReached continuousResult |
	tolerance := 1.0e-9.
	solidPairs := aStepResult pairs reject: [ :pair |
		pair firstBody isSensor or: [ pair secondBody isSensor ] ].
	sensorPairs := aStepResult pairs select: [ :pair |
		pair firstBody isSensor or: [ pair secondBody isSensor ] ].
	impacts := OrderedCollection new.
	impactSolveResults := OrderedCollection new.
	completedBodies := IdentitySet new.
	completedDynamicBodies := IdentitySet new.
	sensorContactsByKey := Dictionary new.
	iterationLimitReached := false.
	[
		remainingSolidPairs := solidPairs reject: [ :pair |
			(self pair: pair includesAnyDynamicBodyFrom: completedDynamicBodies) ].
		initialImpact := impactFinder
			earliestAmong: remainingSolidPairs
			bodyStates: aStepResult bodyStates
			for: aStepResult step timeStep
			afterFraction: tolerance.
		initialImpact notNil
	] whileTrue: [
		continuousBodyStates := componentBuilder
			bodyStatesForImpact: initialImpact
			from: aStepResult bodyStates
			joints: aStepResult joints.
		continuousBodies := continuousBodyStates keys.
		continuousJoints := componentBuilder
			jointsForBodies: continuousBodies
			from: aStepResult joints.
		self
			recordSensorContactsAmong: (sensorPairs select: [ :pair |
				self pair: pair includesAnyDynamicBodyFrom: continuousBodies ])
			bodyStates: aStepResult bodyStates
			for: aStepResult step timeStep
			afterFraction: tolerance
			throughFraction: initialImpact fraction
			into: sensorContactsByKey.
		componentResult := loop
			executeBodyStates: continuousBodyStates
			joints: continuousJoints
			step: aStepResult step
			restitutionThreshold: aStepResult restitutionThreshold.
		componentResult hasImpacts ifFalse: [
			self error: 'A continuous component must contain its detected impact' ].
		impacts addAll: componentResult impacts.
		impactSolveResults addAll: componentResult impactSolveResults.
		completedBodies addAll: componentResult completedBodies.
		completedDynamicBodies addAll: (componentResult completedBodies select: #isDynamic).
		iterationLimitReached := iterationLimitReached or: [ componentResult iterationLimitReached ].
		self commitBodyStatesInOrder: continuousBodyStates ].
	impacts ifEmpty: [
		aStepResult continuousSensorContacts: (self
			sensorContactsAmong: sensorPairs
			bodyStates: aStepResult bodyStates
			for: aStepResult step timeStep
			afterFraction: tolerance).
		aStepResult continuousStepResult: nil.
		^ nil ].
	self
		recordSensorContactsAmong: (sensorPairs reject: [ :pair |
			self pair: pair includesAnyDynamicBodyFrom: completedDynamicBodies ])
		bodyStates: aStepResult bodyStates
		for: aStepResult step timeStep
		afterFraction: tolerance
		throughFraction: 1.0
		into: sensorContactsByKey.
	self recaptureBodyStatesAndPairsOn: aStepResult.
	aStepResult continuousSensorContacts: (self orderedContactsFrom: sensorContactsByKey).
	continuousResult := CFPhysicsContinuousImpactLoopResult
		impacts: impacts
		impactSolveResults: impactSolveResults
		sensorContacts: aStepResult continuousSensorContacts
		bodyStates: aStepResult bodyStates
		remainingTime: 0.0
		iterationLimitReached: iterationLimitReached
		completedBodies: (completedBodies asArray sorted: [ :first :second |
			first sequence < second sequence ]).
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


{ #category : 'private - testing' }
CFPhysicsContinuousStepStage >> pair: pair includesAnyDynamicBodyFrom: bodies [
	^ (pair firstBody isDynamic and: [ bodies includes: pair firstBody ])
		or: [ pair secondBody isDynamic and: [ bodies includes: pair secondBody ] ]
]

{ #category : 'private - sensors' }
CFPhysicsContinuousStepStage >> recordSensorContactsAmong: pairs bodyStates: bodyStates for: seconds afterFraction: minimumFraction throughFraction: maximumFraction into: contactsByKey [
	(self
		sensorContactsAmong: pairs
		bodyStates: bodyStates
		for: seconds
		afterFraction: minimumFraction
		throughFraction: maximumFraction) do: [ :contact |
		contactsByKey at: contact key ifAbsentPut: [ contact ] ]
]

{ #category : 'private - ordering' }
CFPhysicsContinuousStepStage >> orderedContactsFrom: contactsByKey [
	^ contactsByKey values asArray sorted: [ :left :right |
		left pair comesBefore: right pair ]
]


{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> componentBuilder [ ^ componentBuilder ]

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> componentBuilder: anObject [ componentBuilder := anObject ]

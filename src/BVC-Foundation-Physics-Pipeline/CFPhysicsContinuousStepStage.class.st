Class {
	#name : 'CFPhysicsContinuousStepStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'impactFinder', 'pairFinder' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsContinuousStepStage >> initialize [
	super initialize.
	impactFinder := CFPhysicsEarliestImpactFinder new.
	pairFinder := CFPhysicsPairFinder new
]

{ #category : 'executing' }
CFPhysicsContinuousStepStage >> executeOn: aStepResult [
	| solvedPairs solidPairs sensorPairs impacts impactSolveResults sensorContactsByKey continuousResult |
	solvedPairs := pairFinder pairsAmongSolvedStepStates: aStepResult bodyStates values.
	solidPairs := solvedPairs reject: [ :pair |
		pair firstBody isSensor or: [ pair secondBody isSensor ] ].
	sensorPairs := solvedPairs select: [ :pair |
		pair firstBody isSensor or: [ pair secondBody isSensor ] ].
	impacts := OrderedCollection new.
	impactSolveResults := OrderedCollection new.
	sensorContactsByKey := Dictionary new.
	((aStepResult bodyStates values select: #isFastForContinuousCollision) asArray
		sorted: [ :first :second | first body sequence < second body sequence ]) do: [ :state |
		self
			clampSolvedState: state
			amongSolidPairs: solidPairs
			sensorPairs: sensorPairs
			bodyStates: aStepResult bodyStates
			impacts: impacts
			impactSolveResults: impactSolveResults
			sensorContactsByKey: sensorContactsByKey ].
	aStepResult continuousSensorContacts: (self orderedContactsFrom: sensorContactsByKey).
	impacts ifEmpty: [
		aStepResult continuousStepResult: nil.
		^ nil ].
	continuousResult := CFPhysicsContinuousImpactLoopResult
		impacts: impacts
		impactSolveResults: impactSolveResults
		sensorContacts: aStepResult continuousSensorContacts
		bodyStates: aStepResult bodyStates
		remainingTime: 0.0
		iterationLimitReached: false
		completedBodies: #().
	aStepResult continuousStepResult: continuousResult.
	^ continuousResult
]

{ #category : 'private - clamping' }
CFPhysicsContinuousStepStage >> clampSolvedState: state amongSolidPairs: solidPairs sensorPairs: sensorPairs bodyStates: bodyStates impacts: impacts impactSolveResults: impactSolveResults sensorContactsByKey: sensorContactsByKey [
	| body candidates impact maximumFraction impactContact advancement |
	body := state body.
	candidates := solidPairs select: [ :pair |
		(self pair: pair includesBody: body) and: [ self pairHasStaticCounterpart: pair for: body ] ].
	impact := impactFinder
		earliestSolvedAmong: candidates
		bodyStates: bodyStates
		afterFraction: 1.0e-9.
	maximumFraction := impact ifNil: [ 1.0 ] ifNotNil: [ impact fraction ].
	self
		recordSensorContactsAmong: (sensorPairs select: [ :pair |
			(self pair: pair includesBody: body) and: [
			self pairHasStaticCounterpart: pair for: body ] ])
		bodyStates: bodyStates
		throughFraction: maximumFraction
		into: sensorContactsByKey.
	impact ifNil: [ ^ self ].
	impacts add: impact.
	impactContact := self contactForImpact: impact bodyStates: bodyStates.
	advancement := CFPhysicsImpactAdvancementResult
		impact: impact
		elapsedTime: maximumFraction
		remainingTime: 1.0 - maximumFraction.
	impactSolveResults add: (CFPhysicsImpactSolveResult
		advancement: advancement
		contact: impactContact
		constraints: #()).
	state clampSolvedTransformToFraction: maximumFraction
]

{ #category : 'private - contacts' }
CFPhysicsContinuousStepStage >> contactForImpact: impact bodyStates: bodyStates [
	| pair firstSweep secondSweep manifold |
	pair := impact pair.
	firstSweep := (bodyStates at: pair firstBody) solvedSweep.
	secondSweep := (bodyStates at: pair secondBody) solvedSweep.
	manifold := CFPhysicsCollision
		manifoldBetweenShapeState: pair firstBody shapeState
		transform: (firstSweep transformAt: impact fraction)
		andShapeState: pair secondBody shapeState
		transform: (secondSweep transformAt: impact fraction).
	manifold ifNil: [ ^ nil ].
	^ CFPhysicsContact pair: pair manifold: manifold
]

{ #category : 'private - sensors' }
CFPhysicsContinuousStepStage >> recordSensorContactsAmong: pairs bodyStates: bodyStates throughFraction: maximumFraction into: contactsByKey [
	(impactFinder
		solvedImpactsAmong: pairs
		bodyStates: bodyStates
		afterFraction: 1.0e-9) do: [ :impact |
		impact fraction <= (maximumFraction + 1.0e-9) ifTrue: [
			| contact |
			contact := self contactForImpact: impact bodyStates: bodyStates.
			contact ifNotNil: [ contactsByKey at: contact key ifAbsentPut: [ contact ] ] ] ]
]

{ #category : 'private - testing' }
CFPhysicsContinuousStepStage >> pair: pair includesBody: body [
	^ pair firstBody == body or: [ pair secondBody == body ]
]

{ #category : 'private - testing' }
CFPhysicsContinuousStepStage >> pairHasStaticCounterpart: pair for: body [
	pair firstBody == body ifTrue: [ ^ pair secondBody isStatic ].
	^ pair firstBody isStatic
]

{ #category : 'private - ordering' }
CFPhysicsContinuousStepStage >> orderedContactsFrom: contactsByKey [
	^ contactsByKey values asArray sorted: [ :left :right |
		left pair comesBefore: right pair ]
]

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> impactFinder [ ^ impactFinder ]

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> impactFinder: anObject [ impactFinder := anObject ]

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> pairFinder [ ^ pairFinder ]

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> pairFinder: anObject [ pairFinder := anObject ]

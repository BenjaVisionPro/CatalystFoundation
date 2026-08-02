"
I apply continuous-collision handling within the main step pipeline. I find the earliest impact for each fast body and clamp its solved transform to that fraction, matching the Box2D 3.1.1 continuous-collision finalisation path.
"

Class {
	#name : 'CFPhysicsContinuousStepStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'impactFinder', 'pairFinder', 'manifoldGenerator' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
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
	solvedPairs := pairFinder
		pairsAmongSolvedStepStates: aStepResult orderedBodyStates
		collisionSuppressedBodyPairs: aStepResult collisionSuppressedBodyPairs.
	solidPairs := solvedPairs reject: [ :pair |
		self pairIsSensor: pair bodyStates: aStepResult bodyStates ].
	sensorPairs := solvedPairs select: [ :pair |
		self pairIsSensor: pair bodyStates: aStepResult bodyStates ].
	impacts := OrderedCollection new.
	impactSolveResults := OrderedCollection new.
	sensorContactsByKey := Dictionary new.
	(aStepResult orderedBodyStates select: #isFastForContinuousCollision) do: [ :state |
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
	continuousResult := CFPhysicsContinuousStepResult
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
		(self pair: pair includesBody: body) and: [ self pair: pair requiresContinuousCollisionFor: body bodyStates: bodyStates ] ].
	impact := impactFinder
		earliestSolvedAmong: candidates
		bodyStates: bodyStates
		afterFraction: 1.0e-9.
	maximumFraction := impact ifNil: [ 1.0 ] ifNotNil: [ impact fraction ].
	self
		recordSensorContactsAmong: (sensorPairs select: [ :pair |
			(self pair: pair includesBody: body) and: [
			self pair: pair requiresContinuousCollisionFor: body bodyStates: bodyStates ] ])
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
	| pair firstState secondState firstSweep secondSweep manifold |
	pair := impact pair.
	firstState := bodyStates at: pair firstBody.
	secondState := bodyStates at: pair secondBody.
	firstSweep := firstState solvedSweep.
	secondSweep := secondState solvedSweep.
	manifold := manifoldGenerator
		manifoldBetweenShapeState: firstState shapeState
		transform: (firstSweep transformAt: impact fraction)
		andShapeState: secondState shapeState
		transform: (secondSweep transformAt: impact fraction).
	manifold ifNil: [ ^ nil ].
	^ (CFPhysicsContact pair: pair manifold: manifold)
		shapeStatesFromBodyStates: bodyStates;
		yourself
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
CFPhysicsContinuousStepStage >> pairIsSensor: pair bodyStates: bodyStates [
	^ (bodyStates at: pair firstBody) isSensor or: [
		(bodyStates at: pair secondBody) isSensor ]
]

{ #category : 'private - testing' }
CFPhysicsContinuousStepStage >> pair: pair includesBody: body [
	^ pair firstBody == body or: [ pair secondBody == body ]
]

{ #category : 'private - testing' }
CFPhysicsContinuousStepStage >> pair: pair requiresContinuousCollisionFor: body bodyStates: bodyStates [
	| counterpart |
	counterpart := pair firstBody == body
		ifTrue: [ pair secondBody ]
		ifFalse: [ pair firstBody ].
	^ (bodyStates at: body)
		requiresContinuousCollisionAgainst: (bodyStates at: counterpart)
]

{ #category : 'private - ordering' }
CFPhysicsContinuousStepStage >> orderedContactsFrom: contactsByKey [
	^ contactsByKey values asArray sorted: [ :left :right |
		left pair comesBefore: right pair ]
]

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> manifoldGenerator: aManifoldGenerator [
	manifoldGenerator := aManifoldGenerator
]





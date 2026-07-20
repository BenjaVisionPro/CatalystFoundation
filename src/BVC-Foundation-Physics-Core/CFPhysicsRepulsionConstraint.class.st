Class {
	#name : 'CFPhysicsRepulsionConstraint',
	#superclass : 'Object',
	#instVars : [ 'endpointPair', 'distanceResponse', 'active', 'sequence' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsRepulsionConstraint class >> between: firstBodyState and: secondBodyState [
	^ self
		betweenAnchor: (CFPhysicsBodyCentreAnchor on: firstBodyState)
		andAnchor: (CFPhysicsBodyCentreAnchor on: secondBodyState)
]

{ #category : 'instance creation' }
CFPhysicsRepulsionConstraint class >> betweenAnchor: firstAnchor andAnchor: secondAnchor [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair
		anchorA: firstAnchor
		anchorB: secondAnchor)
]

{ #category : 'instance creation' }
CFPhysicsRepulsionConstraint class >> betweenEndpoints: anEndpointPair [
	^ self new
		endpointPair: anEndpointPair;
		yourself
]

{ #category : 'initialization' }
CFPhysicsRepulsionConstraint >> initialize [
	super initialize.
	distanceResponse := CFPhysicsConstantForceResponse new.
	active := true.
	sequence := 0
]

{ #category : 'accessing' }
CFPhysicsRepulsionConstraint >> endpointPair [ ^ endpointPair ]

{ #category : 'accessing' }
CFPhysicsRepulsionConstraint >> endpointPair: anEndpointPair [ endpointPair := anEndpointPair ]

{ #category : 'accessing' }
CFPhysicsRepulsionConstraint >> anchorA [ ^ endpointPair anchorA ]

{ #category : 'accessing' }
CFPhysicsRepulsionConstraint >> anchorB [ ^ endpointPair anchorB ]

{ #category : 'accessing' }
CFPhysicsRepulsionConstraint >> bodyA [ ^ endpointPair bodyA ]

{ #category : 'accessing' }
CFPhysicsRepulsionConstraint >> bodyB [ ^ endpointPair bodyB ]

{ #category : 'configuration' }
CFPhysicsRepulsionConstraint >> distanceResponse [
	^ distanceResponse
]

{ #category : 'configuration' }
CFPhysicsRepulsionConstraint >> distanceResponse: aDistanceResponse [
	distanceResponse := aDistanceResponse
]

{ #category : 'configuration' }
CFPhysicsRepulsionConstraint >> force [
	^ distanceResponse force
]

{ #category : 'configuration' }
CFPhysicsRepulsionConstraint >> force: aNumber [
	distanceResponse force: aNumber
]

{ #category : 'configuration' }
CFPhysicsRepulsionConstraint >> maximumDistance [
	^ distanceResponse maximumDistance
]

{ #category : 'configuration' }
CFPhysicsRepulsionConstraint >> maximumDistance: aNumber [
	distanceResponse maximumDistance: aNumber
]

{ #category : 'testing' }
CFPhysicsRepulsionConstraint >> includesBody: aBodyState [
	^ endpointPair includesBody: aBodyState
]

{ #category : 'testing' }
CFPhysicsRepulsionConstraint >> isActive [
	^ active
]

{ #category : 'ordering' }
CFPhysicsRepulsionConstraint >> orderingKey [
	^ sequence
]

{ #category : 'ordering' }
CFPhysicsRepulsionConstraint >> sequence [
	^ sequence
]

{ #category : 'ordering' }
CFPhysicsRepulsionConstraint >> sequence: anInteger [
	sequence := anInteger
]

{ #category : 'stepping' }
CFPhysicsRepulsionConstraint >> prepareForStep: seconds [
	| points displacement distance direction forceMagnitude impulse firstBody secondBody firstDynamic secondDynamic |
	active ifFalse: [ ^ self ].
	firstBody := self bodyA.
	secondBody := self bodyB.
	firstDynamic := firstBody notNil and: [ firstBody isDynamic ].
	secondDynamic := secondBody notNil and: [ secondBody isDynamic ].
	(firstDynamic or: [ secondDynamic ]) ifFalse: [ ^ self ].
	points := endpointPair worldPoints.
	displacement := points second - points first.
	distance := displacement r.
	distance = 0 ifTrue: [ ^ self ].
	forceMagnitude := distanceResponse forceMagnitudeAtDistance: distance.
	forceMagnitude = 0 ifTrue: [ ^ self ].
	direction := displacement / distance.
	impulse := direction * (forceMagnitude * seconds).
	firstDynamic ifTrue: [
		firstBody addVelocity: impulse negated * firstBody inverseMass ].
	secondDynamic ifTrue: [
		secondBody addVelocity: impulse * secondBody inverseMass ].
	firstDynamic ifTrue: [ firstBody wake ].
	secondDynamic ifTrue: [ secondBody wake ]
]

{ #category : 'controlling' }
CFPhysicsRepulsionConstraint >> release [
	active := false
]

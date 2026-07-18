Class {
	#name : 'CFPhysicsRepulsionConstraint',
	#superclass : 'Object',
	#instVars : [ 'endpointPair', 'distanceResponse', 'active', 'sequence' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
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
	| displacement distance direction forceMagnitude impulse firstBody secondBody |
	active ifFalse: [ ^ self ].
	firstBody := self bodyA.
	secondBody := self bodyB.
	(firstBody isDynamic or: [ secondBody isDynamic ]) ifFalse: [ ^ self ].
	displacement := endpointPair worldPointB - endpointPair worldPointA.
	distance := displacement r.
	distance = 0 ifTrue: [ ^ self ].
	forceMagnitude := distanceResponse forceMagnitudeAtDistance: distance.
	forceMagnitude = 0 ifTrue: [ ^ self ].
	direction := displacement / distance.
	impulse := direction * (forceMagnitude * seconds).
	firstBody isDynamic ifTrue: [
		firstBody addVelocity: impulse negated * firstBody inverseMass ].
	secondBody isDynamic ifTrue: [
		secondBody addVelocity: impulse * secondBody inverseMass ].
	firstBody wake.
	secondBody wake
]

{ #category : 'controlling' }
CFPhysicsRepulsionConstraint >> release [
	active := false
]

Class {
	#name : 'CFPhysicsAttractionConstraint',
	#superclass : 'Object',
	#instVars : [ 'endpointPair', 'distanceResponse', 'active', 'sequence' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsAttractionConstraint class >> between: firstBodyState and: secondBodyState [
	^ self
		betweenAnchor: (CFPhysicsBodyCentreAnchor on: firstBodyState)
		andAnchor: (CFPhysicsBodyCentreAnchor on: secondBodyState)
]

{ #category : 'instance creation' }
CFPhysicsAttractionConstraint class >> betweenAnchor: firstAnchor andAnchor: secondAnchor [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair
		anchorA: firstAnchor
		anchorB: secondAnchor)
]

{ #category : 'instance creation' }
CFPhysicsAttractionConstraint class >> betweenEndpoints: anEndpointPair [
	^ self new
		endpointPair: anEndpointPair;
		yourself
]

{ #category : 'initialization' }
CFPhysicsAttractionConstraint >> initialize [
	super initialize.
	distanceResponse := CFPhysicsConstantForceResponse new.
	active := true.
	sequence := 0
]

{ #category : 'accessing' }
CFPhysicsAttractionConstraint >> endpointPair [ ^ endpointPair ]

{ #category : 'accessing' }
CFPhysicsAttractionConstraint >> endpointPair: anEndpointPair [ endpointPair := anEndpointPair ]

{ #category : 'accessing' }
CFPhysicsAttractionConstraint >> anchorA [ ^ endpointPair anchorA ]

{ #category : 'accessing' }
CFPhysicsAttractionConstraint >> anchorB [ ^ endpointPair anchorB ]

{ #category : 'accessing' }
CFPhysicsAttractionConstraint >> bodyA [ ^ endpointPair bodyA ]

{ #category : 'accessing' }
CFPhysicsAttractionConstraint >> bodyB [ ^ endpointPair bodyB ]

{ #category : 'configuration' }
CFPhysicsAttractionConstraint >> distanceResponse [
	^ distanceResponse
]

{ #category : 'configuration' }
CFPhysicsAttractionConstraint >> distanceResponse: aDistanceResponse [
	distanceResponse := aDistanceResponse
]

{ #category : 'configuration' }
CFPhysicsAttractionConstraint >> force [
	^ distanceResponse force
]

{ #category : 'configuration' }
CFPhysicsAttractionConstraint >> force: aNumber [
	distanceResponse force: aNumber
]

{ #category : 'configuration' }
CFPhysicsAttractionConstraint >> maximumDistance [
	^ distanceResponse maximumDistance
]

{ #category : 'configuration' }
CFPhysicsAttractionConstraint >> maximumDistance: aNumber [
	distanceResponse maximumDistance: aNumber
]

{ #category : 'testing' }
CFPhysicsAttractionConstraint >> includesBody: aBodyState [
	^ endpointPair includesBody: aBodyState
]

{ #category : 'testing' }
CFPhysicsAttractionConstraint >> isActive [
	^ active
]

{ #category : 'ordering' }
CFPhysicsAttractionConstraint >> orderingKey [
	^ sequence
]

{ #category : 'ordering' }
CFPhysicsAttractionConstraint >> sequence [
	^ sequence
]

{ #category : 'ordering' }
CFPhysicsAttractionConstraint >> sequence: anInteger [
	sequence := anInteger
]

{ #category : 'stepping' }
CFPhysicsAttractionConstraint >> prepareForStep: seconds [
	| points displacement distance direction forceMagnitude impulse firstBody secondBody |
	active ifFalse: [ ^ self ].
	firstBody := self bodyA.
	secondBody := self bodyB.
	points := endpointPair worldPoints.
	displacement := points second - points first.
	distance := displacement r.
	distance = 0 ifTrue: [ ^ self ].
	forceMagnitude := distanceResponse forceMagnitudeAtDistance: distance.
	forceMagnitude = 0 ifTrue: [ ^ self ].
	direction := displacement / distance.
	impulse := direction * (forceMagnitude * seconds).
	firstBody ifNotNil: [
		firstBody addVelocity: impulse * firstBody inverseMass ].
	secondBody ifNotNil: [
		secondBody addVelocity: impulse negated * secondBody inverseMass ].
	firstBody ifNotNil: [ firstBody wake ].
	secondBody ifNotNil: [ secondBody wake ]
]

{ #category : 'controlling' }
CFPhysicsAttractionConstraint >> release [
	active := false
]

Class {
	#name : 'CFPhysicsAttractionConstraint',
	#superclass : 'Object',
	#instVars : [ 'anchorA', 'anchorB', 'distanceResponse', 'active', 'sequence' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
}

{ #category : 'instance creation' }
CFPhysicsAttractionConstraint class >> between: firstBodyState and: secondBodyState [
	^ self
		betweenAnchor: (CFPhysicsBodyCentreAnchor on: firstBodyState)
		andAnchor: (CFPhysicsBodyCentreAnchor on: secondBodyState)
]

{ #category : 'instance creation' }
CFPhysicsAttractionConstraint class >> betweenAnchor: firstAnchor andAnchor: secondAnchor [
	^ self new
		anchorA: firstAnchor;
		anchorB: secondAnchor;
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
CFPhysicsAttractionConstraint >> anchorA [
	^ anchorA
]

{ #category : 'accessing' }
CFPhysicsAttractionConstraint >> anchorA: anAnchor [
	anchorA := anAnchor
]

{ #category : 'accessing' }
CFPhysicsAttractionConstraint >> anchorB [
	^ anchorB
]

{ #category : 'accessing' }
CFPhysicsAttractionConstraint >> anchorB: anAnchor [
	anchorB := anAnchor
]

{ #category : 'accessing' }
CFPhysicsAttractionConstraint >> bodyA [
	^ anchorA body
]

{ #category : 'accessing' }
CFPhysicsAttractionConstraint >> bodyB [
	^ anchorB body
]

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
	^ self bodyA == aBodyState or: [ self bodyB == aBodyState ]
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
	| displacement distance direction forceMagnitude impulse firstBody secondBody |
	active ifFalse: [ ^ self ].
	firstBody := self bodyA.
	secondBody := self bodyB.
	(firstBody isDynamic or: [ secondBody isDynamic ]) ifFalse: [ ^ self ].
	displacement := anchorB worldPoint - anchorA worldPoint.
	distance := displacement r.
	distance = 0 ifTrue: [ ^ self ].
	forceMagnitude := distanceResponse forceMagnitudeAtDistance: distance.
	forceMagnitude = 0 ifTrue: [ ^ self ].
	direction := displacement / distance.
	impulse := direction * (forceMagnitude * seconds).
	firstBody isDynamic ifTrue: [
		firstBody addVelocity: impulse * firstBody inverseMass ].
	secondBody isDynamic ifTrue: [
		secondBody addVelocity: impulse negated * secondBody inverseMass ].
	firstBody wake.
	secondBody wake
]

{ #category : 'controlling' }
CFPhysicsAttractionConstraint >> release [
	active := false
]

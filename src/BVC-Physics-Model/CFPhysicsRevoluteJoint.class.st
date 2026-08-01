"
I represent a joint that keeps two anchors coincident while allowing relative rotation.

My responsibility is to retain its reference angle, limits, motor configuration and accumulated solver state.
"
Class {
	#name : 'CFPhysicsRevoluteJoint',
	#superclass : 'CFPhysicsJoint',
	#instVars : [ 'endpointPair', 'accumulatedImpulse', 'referenceAngle', 'limitsEnabled', 'lowerAngle', 'upperAngle', 'motorEnabled', 'motorSpeed', 'maximumMotorTorque', 'motorImpulse', 'lowerLimitImpulse', 'upperLimitImpulse', 'springEnabled', 'hertz', 'dampingRatio', 'targetAngle', 'springImpulse' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsRevoluteJoint class >> between: bodyA and: bodyB [
	^ self
		betweenAnchor: (CFPhysicsBodyCentreAnchor on: bodyA)
		andAnchor: (CFPhysicsBodyCentreAnchor on: bodyB)
]

{ #category : 'instance creation' }
CFPhysicsRevoluteJoint class >> betweenAnchor: firstAnchor andAnchor: secondAnchor [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair
		anchorA: firstAnchor
		anchorB: secondAnchor)
]

{ #category : 'instance creation' }
CFPhysicsRevoluteJoint class >> betweenEndpoints: anEndpointPair [
	^ self new
		endpointPair: anEndpointPair;
		referenceAngle: ((self angleFor: anEndpointPair bodyB) - (self angleFor: anEndpointPair bodyA));
		yourself
]

{ #category : 'private' }
CFPhysicsRevoluteJoint class >> angleFor: aBody [
	^ aBody ifNil: [ 0.0 ] ifNotNil: [ aBody rotation ]
]

{ #category : 'initialization' }
CFPhysicsRevoluteJoint >> initialize [
	super initialize.
	accumulatedImpulse := 0 @ 0.
	referenceAngle := 0.0.
	limitsEnabled := false.
	lowerAngle := 0.0.
	upperAngle := 0.0.
	motorEnabled := false.
	motorSpeed := 0.0.
	maximumMotorTorque := 0.0.
	motorImpulse := 0.0.
	lowerLimitImpulse := 0.0.
	upperLimitImpulse := 0.0.
	springEnabled := false.
	hertz := 0.0.
	dampingRatio := 0.0.
	targetAngle := 0.0.
	springImpulse := 0.0.
]

{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> endpointPair [ ^ endpointPair ]
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> endpointPair: anEndpointPair [ endpointPair := anEndpointPair ]
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> anchorA [ ^ endpointPair anchorA ]
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> anchorB [ ^ endpointPair anchorB ]
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> bodyA [ ^ endpointPair bodyA ]
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> bodyB [ ^ endpointPair bodyB ]




{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> accumulatedImpulse [ ^ accumulatedImpulse ]
{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> accumulatedImpulse: aPoint [ accumulatedImpulse := aPoint ]

{ #category : 'configuration' }
CFPhysicsRevoluteJoint >> referenceAngle [ ^ referenceAngle ]
{ #category : 'configuration' }
CFPhysicsRevoluteJoint >> referenceAngle: aNumber [
	referenceAngle := aNumber asFloat.
	self wakeBodies
]


{ #category : 'spring' }
CFPhysicsRevoluteJoint >> springEnabled [ ^ springEnabled ]
{ #category : 'spring' }
CFPhysicsRevoluteJoint >> springEnabled: aBoolean [
	springEnabled = aBoolean ifTrue: [ ^ self ].
	springEnabled := aBoolean.
	springImpulse := 0.0.
	self wakeBodies
]
{ #category : 'spring' }
CFPhysicsRevoluteJoint >> hertz [ ^ hertz ]
{ #category : 'spring' }
CFPhysicsRevoluteJoint >> hertz: aNumber [
	hertz := aNumber asFloat max: 0.0.
	self wakeBodies
]
{ #category : 'spring' }
CFPhysicsRevoluteJoint >> dampingRatio [ ^ dampingRatio ]
{ #category : 'spring' }
CFPhysicsRevoluteJoint >> dampingRatio: aNumber [
	dampingRatio := aNumber asFloat max: 0.0.
	self wakeBodies
]
{ #category : 'spring' }
CFPhysicsRevoluteJoint >> targetAngle [ ^ targetAngle ]
{ #category : 'spring' }
CFPhysicsRevoluteJoint >> targetAngle: aNumber [
	targetAngle := aNumber asFloat.
	self wakeBodies
]
{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> springImpulse [ ^ springImpulse ]
{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> springImpulse: aNumber [ springImpulse := aNumber asFloat ]

{ #category : 'limits' }
CFPhysicsRevoluteJoint >> limitsEnabled [ ^ limitsEnabled ]

{ #category : 'limits' }
CFPhysicsRevoluteJoint >> limitsEnabled: aBoolean [
	limitsEnabled = aBoolean ifTrue: [ ^ self ].
	limitsEnabled := aBoolean.
	lowerLimitImpulse := 0.0.
	upperLimitImpulse := 0.0.
	self wakeBodies
]
{ #category : 'limits' }
CFPhysicsRevoluteJoint >> lowerAngle [ ^ lowerAngle ]
{ #category : 'limits' }
CFPhysicsRevoluteJoint >> upperAngle [ ^ upperAngle ]
{ #category : 'limits' }
CFPhysicsRevoluteJoint >> limitAnglesFrom: aLowerAngle to: anUpperAngle [
	| lower upper |
	lower := aLowerAngle asFloat.
	upper := anUpperAngle asFloat.
	lower <= upper ifFalse: [ self error: 'A revolute joint limit requires a lower angle no greater than its upper angle' ].
	lowerAngle := lower.
	upperAngle := upper.
	lowerLimitImpulse := 0.0.
	upperLimitImpulse := 0.0.
	self wakeBodies
]


{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> lowerLimitImpulse [ ^ lowerLimitImpulse ]
{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> lowerLimitImpulse: aNumber [ lowerLimitImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> upperLimitImpulse [ ^ upperLimitImpulse ]
{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> upperLimitImpulse: aNumber [ upperLimitImpulse := aNumber asFloat ]

{ #category : 'motor' }
CFPhysicsRevoluteJoint >> motorEnabled [ ^ motorEnabled ]

{ #category : 'motor' }
CFPhysicsRevoluteJoint >> motorEnabled: aBoolean [
	motorEnabled = aBoolean ifTrue: [ ^ self ].
	motorEnabled := aBoolean.
	motorImpulse := 0.0.
	self wakeBodies
]
{ #category : 'motor' }
CFPhysicsRevoluteJoint >> motorSpeed [ ^ motorSpeed ]
{ #category : 'motor' }
CFPhysicsRevoluteJoint >> motorSpeed: aNumber [
	motorSpeed := aNumber asFloat.
	self wakeBodies
]
{ #category : 'motor' }
CFPhysicsRevoluteJoint >> maximumMotorTorque [ ^ maximumMotorTorque ]
{ #category : 'motor' }
CFPhysicsRevoluteJoint >> maximumMotorTorque: aNumber [
	maximumMotorTorque := aNumber asFloat max: 0.0.
	self wakeBodies
]
{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> motorImpulse [ ^ motorImpulse ]
{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> motorImpulse: aNumber [ motorImpulse := aNumber asFloat ]


{ #category : 'testing' }
CFPhysicsRevoluteJoint >> includesBody: aBodyState [ ^ endpointPair includesBody: aBodyState ]

{ #category : 'testing' }
CFPhysicsRevoluteJoint >> includesAnchor: anAnchor [
	(endpointPair respondsTo: #anchorA) ifFalse: [ ^ false ].
	^ endpointPair anchorA == anAnchor or: [ endpointPair anchorB == anAnchor ]
]




{ #category : 'capturing' }
CFPhysicsRevoluteJoint >> capturedForStep [
	| captured |
	captured := self shallowCopy.
	captured
		endpointPair: (CFPhysicsCapturedEndpointPair from: endpointPair);
		sourceJoint: self.
	^ captured
]



Class {
	#name : 'CFPhysicsRevoluteJoint',
	#superclass : 'Object',
	#instVars : [ 'endpointPair', 'active', 'sequence', 'accumulatedImpulse', 'referenceAngle', 'limitsEnabled', 'lowerAngle', 'upperAngle', 'motorEnabled', 'motorSpeed', 'maximumMotorImpulse', 'motorImpulse' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsRevoluteJoint class >> between: firstBodyState and: secondBodyState [
	^ self
		betweenAnchor: (CFPhysicsBodyCentreAnchor on: firstBodyState)
		andAnchor: (CFPhysicsBodyCentreAnchor on: secondBodyState)
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
	active := true.
	sequence := 0.
	accumulatedImpulse := 0 @ 0.
	referenceAngle := 0.0.
	limitsEnabled := false.
	lowerAngle := 0.0.
	upperAngle := 0.0.
	motorEnabled := false.
	motorSpeed := 0.0.
	maximumMotorImpulse := 0.0.
	motorImpulse := 0.0
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
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> firstBody [ ^ self bodyA ]
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> secondBody [ ^ self bodyB ]

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

{ #category : 'limits' }
CFPhysicsRevoluteJoint >> limitsEnabled [ ^ limitsEnabled ]
{ #category : 'limits' }
CFPhysicsRevoluteJoint >> limitsEnabled: aBoolean [
	limitsEnabled = aBoolean ifTrue: [ ^ self ].
	limitsEnabled := aBoolean.
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
	lower < upper ifFalse: [ self error: 'A revolute joint limit requires a lower angle smaller than its upper angle' ].
	lowerAngle := lower.
	upperAngle := upper.
	self wakeBodies
]

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
	motorImpulse := 0.0.
	self wakeBodies
]
{ #category : 'motor' }
CFPhysicsRevoluteJoint >> maximumMotorImpulse [ ^ maximumMotorImpulse ]
{ #category : 'motor' }
CFPhysicsRevoluteJoint >> maximumMotorImpulse: aNumber [
	maximumMotorImpulse := aNumber asFloat max: 0.0.
	motorImpulse := 0.0.
	self wakeBodies
]
{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> motorImpulse [ ^ motorImpulse ]
{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> motorImpulse: aNumber [ motorImpulse := aNumber asFloat ]

{ #category : 'ordering' }
CFPhysicsRevoluteJoint >> sequence [ ^ sequence ]
{ #category : 'ordering' }
CFPhysicsRevoluteJoint >> sequence: anInteger [ sequence := anInteger ]
{ #category : 'ordering' }
CFPhysicsRevoluteJoint >> orderingKey [ ^ sequence ]

{ #category : 'testing' }
CFPhysicsRevoluteJoint >> isActive [ ^ active ]
{ #category : 'testing' }
CFPhysicsRevoluteJoint >> includesBody: aBodyState [ ^ endpointPair includesBody: aBodyState ]

{ #category : 'testing' }
CFPhysicsRevoluteJoint >> includesAnchor: anAnchor [
	(endpointPair respondsTo: #anchorA) ifFalse: [ ^ false ].
	^ endpointPair anchorA == anAnchor or: [ endpointPair anchorB == anAnchor ]
]

{ #category : 'waking' }
CFPhysicsRevoluteJoint >> wakeBodies [
	self firstBody ifNotNil: [ :body | body wake ].
	self secondBody ifNotNil: [ :body | body wake ]
]

{ #category : 'controlling' }
CFPhysicsRevoluteJoint >> release [ active := false ]

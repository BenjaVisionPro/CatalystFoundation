"I represent a Box2D 3.1.1 wheel joint.

My responsibility is to constrain body B to body A's local axis while allowing relative rotation, with optional axial spring, translation limits and rotational motor.
"
Class {
	#name : 'CFPhysicsWheelJoint',
	#superclass : 'CFPhysicsJoint',
	#instVars : [ 'endpointPair', 'localAxisA', 'springEnabled', 'hertz', 'dampingRatio', 'limitsEnabled', 'lowerTranslation', 'upperTranslation', 'motorEnabled', 'maximumMotorTorque', 'motorSpeed', 'perpendicularImpulse', 'springImpulse', 'lowerLimitImpulse', 'upperLimitImpulse', 'motorImpulse' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsWheelJoint class >> between: bodyA and: bodyB along: aWorldAxis [
	^ self betweenAnchor: (CFPhysicsBodyCentreAnchor on: bodyA) andAnchor: (CFPhysicsBodyCentreAnchor on: bodyB) along: aWorldAxis
]

{ #category : 'instance creation' }
CFPhysicsWheelJoint class >> betweenAnchor: anchorA andAnchor: anchorB along: aWorldAxis [
	| endpoints |
	endpoints := (anchorA body notNil and: [ anchorB body isNil ])
		ifTrue: [ CFPhysicsAnchoredEndpointPair anchorA: anchorB anchorB: anchorA ]
		ifFalse: [ CFPhysicsAnchoredEndpointPair anchorA: anchorA anchorB: anchorB ].
	^ self betweenEndpoints: endpoints along: aWorldAxis
]

{ #category : 'instance creation' }
CFPhysicsWheelJoint class >> betweenEndpoints: endpoints along: aWorldAxis [
	| bodyA localAxis |
	bodyA := endpoints bodyA.
	localAxis := bodyA
		ifNil: [ aWorldAxis ]
		ifNotNil: [ bodyA bodyLocalVectorForWorldVector: aWorldAxis ].
	^ self new endpointPair: endpoints; localAxisA: localAxis; yourself
]

{ #category : 'initialization' }
CFPhysicsWheelJoint >> initialize [
	super initialize.
	localAxisA := 0 @ 1.
	springEnabled := true.
	hertz := 1.0.
	dampingRatio := 0.7.
	limitsEnabled := false.
	lowerTranslation := 0.0.
	upperTranslation := 0.0.
	motorEnabled := false.
	maximumMotorTorque := 0.0.
	motorSpeed := 0.0.
	perpendicularImpulse := 0.0.
	springImpulse := 0.0.
	lowerLimitImpulse := 0.0.
	upperLimitImpulse := 0.0.
	motorImpulse := 0.0
]

{ #category : 'accessing' }
CFPhysicsWheelJoint >> endpointPair [ ^ endpointPair ]
{ #category : 'accessing' }
CFPhysicsWheelJoint >> endpointPair: anEndpointPair [ endpointPair := anEndpointPair ]
{ #category : 'accessing' }
CFPhysicsWheelJoint >> anchorA [ ^ endpointPair anchorA ]
{ #category : 'accessing' }
CFPhysicsWheelJoint >> anchorB [ ^ endpointPair anchorB ]
{ #category : 'accessing' }
CFPhysicsWheelJoint >> bodyA [ ^ endpointPair bodyA ]
{ #category : 'accessing' }
CFPhysicsWheelJoint >> bodyB [ ^ endpointPair bodyB ]

{ #category : 'configuration' }
CFPhysicsWheelJoint >> localAxisA [ ^ localAxisA ]
{ #category : 'configuration' }
CFPhysicsWheelJoint >> localAxisA: aPoint [
	| length |
	length := aPoint r.
	length = 0.0 ifTrue: [ self error: 'A wheel joint requires a non-zero local axis' ].
	localAxisA := aPoint / length.
	self resetLinearImpulses; wakeBodies
]

{ #category : 'spring' }
CFPhysicsWheelJoint >> springEnabled [ ^ springEnabled ]
{ #category : 'spring' }
CFPhysicsWheelJoint >> springEnabled: aBoolean [ springEnabled = aBoolean ifTrue: [ ^ self ]. springEnabled := aBoolean. springImpulse := 0.0. self wakeBodies ]
{ #category : 'spring' }
CFPhysicsWheelJoint >> hertz [ ^ hertz ]
{ #category : 'spring' }
CFPhysicsWheelJoint >> hertz: aNumber [ hertz := aNumber asFloat max: 0.0. self wakeBodies ]
{ #category : 'spring' }
CFPhysicsWheelJoint >> dampingRatio [ ^ dampingRatio ]
{ #category : 'spring' }
CFPhysicsWheelJoint >> dampingRatio: aNumber [ dampingRatio := aNumber asFloat max: 0.0. self wakeBodies ]

{ #category : 'limits' }
CFPhysicsWheelJoint >> limitsEnabled [ ^ limitsEnabled ]
{ #category : 'limits' }
CFPhysicsWheelJoint >> limitsEnabled: aBoolean [ limitsEnabled = aBoolean ifTrue: [ ^ self ]. limitsEnabled := aBoolean. lowerLimitImpulse := 0.0. upperLimitImpulse := 0.0. self wakeBodies ]
{ #category : 'limits' }
CFPhysicsWheelJoint >> lowerTranslation [ ^ lowerTranslation ]
{ #category : 'limits' }
CFPhysicsWheelJoint >> upperTranslation [ ^ upperTranslation ]
{ #category : 'limits' }
CFPhysicsWheelJoint >> limitTranslationFrom: lower to: upper [
	lower asFloat <= upper asFloat ifFalse: [ self error: 'A wheel joint lower translation must not exceed its upper translation' ].
	lowerTranslation := lower asFloat.
	upperTranslation := upper asFloat.
	lowerLimitImpulse := 0.0.
	upperLimitImpulse := 0.0.
	self wakeBodies
]

{ #category : 'motor' }
CFPhysicsWheelJoint >> motorEnabled [ ^ motorEnabled ]
{ #category : 'motor' }
CFPhysicsWheelJoint >> motorEnabled: aBoolean [ motorEnabled = aBoolean ifTrue: [ ^ self ]. motorEnabled := aBoolean. motorImpulse := 0.0. self wakeBodies ]
{ #category : 'motor' }
CFPhysicsWheelJoint >> maximumMotorTorque [ ^ maximumMotorTorque ]
{ #category : 'motor' }
CFPhysicsWheelJoint >> maximumMotorTorque: aNumber [ maximumMotorTorque := aNumber asFloat max: 0.0. self wakeBodies ]
{ #category : 'motor' }
CFPhysicsWheelJoint >> motorSpeed [ ^ motorSpeed ]
{ #category : 'motor' }
CFPhysicsWheelJoint >> motorSpeed: aNumber [ motorSpeed := aNumber asFloat. self wakeBodies ]

{ #category : 'solver state' }
CFPhysicsWheelJoint >> perpendicularImpulse [ ^ perpendicularImpulse ]
{ #category : 'solver state' }
CFPhysicsWheelJoint >> perpendicularImpulse: aNumber [ perpendicularImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsWheelJoint >> springImpulse [ ^ springImpulse ]
{ #category : 'solver state' }
CFPhysicsWheelJoint >> springImpulse: aNumber [ springImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsWheelJoint >> lowerLimitImpulse [ ^ lowerLimitImpulse ]
{ #category : 'solver state' }
CFPhysicsWheelJoint >> lowerLimitImpulse: aNumber [ lowerLimitImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsWheelJoint >> upperLimitImpulse [ ^ upperLimitImpulse ]
{ #category : 'solver state' }
CFPhysicsWheelJoint >> upperLimitImpulse: aNumber [ upperLimitImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsWheelJoint >> motorImpulse [ ^ motorImpulse ]
{ #category : 'solver state' }
CFPhysicsWheelJoint >> motorImpulse: aNumber [ motorImpulse := aNumber asFloat ]

{ #category : 'private' }
CFPhysicsWheelJoint >> resetLinearImpulses [ perpendicularImpulse := 0.0. springImpulse := 0.0. lowerLimitImpulse := 0.0. upperLimitImpulse := 0.0 ]

{ #category : 'testing' }
CFPhysicsWheelJoint >> includesBody: aBody [ ^ endpointPair includesBody: aBody ]
{ #category : 'testing' }
CFPhysicsWheelJoint >> includesAnchor: anAnchor [ ^ endpointPair anchorA == anAnchor or: [ endpointPair anchorB == anAnchor ] ]

{ #category : 'capturing' }
CFPhysicsWheelJoint >> capturedForStep [
	| captured |
	captured := self shallowCopy.
	captured endpointPair: (CFPhysicsCapturedEndpointPair from: endpointPair); sourceJoint: self.
	^ captured
]

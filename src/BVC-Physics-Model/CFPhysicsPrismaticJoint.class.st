"I represent a Box2D 3.1.1 prismatic joint.

My responsibility is to constrain body B to translate along body A's local axis while locking relative rotation, with optional axial spring, translation limits and motor.
"
Class {
	#name : 'CFPhysicsPrismaticJoint',
	#superclass : 'CFPhysicsJoint',
	#instVars : [ 'endpointPair', 'localAxisA', 'referenceAngle', 'springEnabled', 'hertz', 'dampingRatio', 'targetTranslation', 'limitsEnabled', 'lowerTranslation', 'upperTranslation', 'motorEnabled', 'maximumMotorForce', 'motorSpeed', 'perpendicularImpulse', 'angularImpulse', 'springImpulse', 'lowerLimitImpulse', 'upperLimitImpulse', 'motorImpulse' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsPrismaticJoint class >> between: bodyA and: bodyB along: aWorldAxis [
	^ self betweenAnchor: (CFPhysicsBodyCentreAnchor on: bodyA) andAnchor: (CFPhysicsBodyCentreAnchor on: bodyB) along: aWorldAxis
]

{ #category : 'instance creation' }
CFPhysicsPrismaticJoint class >> betweenAnchor: anchorA andAnchor: anchorB along: aWorldAxis [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair anchorA: anchorA anchorB: anchorB) along: aWorldAxis
]

{ #category : 'instance creation' }
CFPhysicsPrismaticJoint class >> betweenEndpoints: endpoints along: aWorldAxis [
	| bodyA localAxis |
	bodyA := endpoints bodyA.
	localAxis := bodyA
		ifNil: [ aWorldAxis ]
		ifNotNil: [ bodyA bodyLocalVectorForWorldVector: aWorldAxis ].
	^ self new
		endpointPair: endpoints;
		localAxisA: localAxis;
		referenceAngle: ((self angleFor: endpoints bodyB) - (self angleFor: bodyA));
		yourself
]

{ #category : 'private' }
CFPhysicsPrismaticJoint class >> angleFor: aBody [ ^ aBody ifNil: [ 0.0 ] ifNotNil: [ aBody rotation ] ]

{ #category : 'initialization' }
CFPhysicsPrismaticJoint >> initialize [
	super initialize.
	localAxisA := 1 @ 0.
	referenceAngle := 0.0.
	springEnabled := false.
	hertz := 0.0.
	dampingRatio := 0.0.
	targetTranslation := 0.0.
	limitsEnabled := false.
	lowerTranslation := 0.0.
	upperTranslation := 0.0.
	motorEnabled := false.
	maximumMotorForce := 0.0.
	motorSpeed := 0.0.
	perpendicularImpulse := 0.0.
	angularImpulse := 0.0.
	springImpulse := 0.0.
	lowerLimitImpulse := 0.0.
	upperLimitImpulse := 0.0.
	motorImpulse := 0.0
]

{ #category : 'accessing' }
CFPhysicsPrismaticJoint >> endpointPair [ ^ endpointPair ]
{ #category : 'accessing' }
CFPhysicsPrismaticJoint >> endpointPair: anEndpointPair [ endpointPair := anEndpointPair ]
{ #category : 'accessing' }
CFPhysicsPrismaticJoint >> anchorA [ ^ endpointPair anchorA ]
{ #category : 'accessing' }
CFPhysicsPrismaticJoint >> anchorB [ ^ endpointPair anchorB ]
{ #category : 'accessing' }
CFPhysicsPrismaticJoint >> bodyA [ ^ endpointPair bodyA ]
{ #category : 'accessing' }
CFPhysicsPrismaticJoint >> bodyB [ ^ endpointPair bodyB ]

{ #category : 'configuration' }
CFPhysicsPrismaticJoint >> localAxisA [ ^ localAxisA ]
{ #category : 'configuration' }
CFPhysicsPrismaticJoint >> localAxisA: aPoint [
	| length |
	length := aPoint r.
	length = 0.0 ifTrue: [ self error: 'A prismatic joint requires a non-zero local axis' ].
	localAxisA := aPoint / length.
	self resetAxialImpulses; resetPerpendicularImpulse; wakeBodies
]
{ #category : 'configuration' }
CFPhysicsPrismaticJoint >> referenceAngle [ ^ referenceAngle ]
{ #category : 'configuration' }
CFPhysicsPrismaticJoint >> referenceAngle: aNumber [ referenceAngle := aNumber asFloat. angularImpulse := 0.0. self wakeBodies ]

{ #category : 'spring' }
CFPhysicsPrismaticJoint >> springEnabled [ ^ springEnabled ]
{ #category : 'spring' }
CFPhysicsPrismaticJoint >> springEnabled: aBoolean [ springEnabled = aBoolean ifTrue: [ ^ self ]. springEnabled := aBoolean. springImpulse := 0.0. self wakeBodies ]
{ #category : 'spring' }
CFPhysicsPrismaticJoint >> hertz [ ^ hertz ]
{ #category : 'spring' }
CFPhysicsPrismaticJoint >> hertz: aNumber [ hertz := aNumber asFloat max: 0.0. springImpulse := 0.0. self wakeBodies ]
{ #category : 'spring' }
CFPhysicsPrismaticJoint >> dampingRatio [ ^ dampingRatio ]
{ #category : 'spring' }
CFPhysicsPrismaticJoint >> dampingRatio: aNumber [ dampingRatio := aNumber asFloat max: 0.0. springImpulse := 0.0. self wakeBodies ]
{ #category : 'spring' }
CFPhysicsPrismaticJoint >> targetTranslation [ ^ targetTranslation ]
{ #category : 'spring' }
CFPhysicsPrismaticJoint >> targetTranslation: aNumber [ targetTranslation := aNumber asFloat. springImpulse := 0.0. self wakeBodies ]

{ #category : 'limits' }
CFPhysicsPrismaticJoint >> limitsEnabled [ ^ limitsEnabled ]
{ #category : 'limits' }
CFPhysicsPrismaticJoint >> limitsEnabled: aBoolean [ limitsEnabled = aBoolean ifTrue: [ ^ self ]. limitsEnabled := aBoolean. lowerLimitImpulse := 0.0. upperLimitImpulse := 0.0. self wakeBodies ]
{ #category : 'limits' }
CFPhysicsPrismaticJoint >> lowerTranslation [ ^ lowerTranslation ]
{ #category : 'limits' }
CFPhysicsPrismaticJoint >> upperTranslation [ ^ upperTranslation ]
{ #category : 'limits' }
CFPhysicsPrismaticJoint >> limitTranslationFrom: lower to: upper [
	lower asFloat <= upper asFloat ifFalse: [ self error: 'A prismatic joint lower translation must not exceed its upper translation' ].
	lowerTranslation := lower asFloat. upperTranslation := upper asFloat.
	lowerLimitImpulse := 0.0. upperLimitImpulse := 0.0. self wakeBodies
]

{ #category : 'motor' }
CFPhysicsPrismaticJoint >> motorEnabled [ ^ motorEnabled ]
{ #category : 'motor' }
CFPhysicsPrismaticJoint >> motorEnabled: aBoolean [ motorEnabled = aBoolean ifTrue: [ ^ self ]. motorEnabled := aBoolean. motorImpulse := 0.0. self wakeBodies ]
{ #category : 'motor' }
CFPhysicsPrismaticJoint >> maximumMotorForce [ ^ maximumMotorForce ]
{ #category : 'motor' }
CFPhysicsPrismaticJoint >> maximumMotorForce: aNumber [ maximumMotorForce := aNumber asFloat max: 0.0. motorImpulse := 0.0. self wakeBodies ]
{ #category : 'motor' }
CFPhysicsPrismaticJoint >> motorSpeed [ ^ motorSpeed ]
{ #category : 'motor' }
CFPhysicsPrismaticJoint >> motorSpeed: aNumber [ motorSpeed := aNumber asFloat. self wakeBodies ]

{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> perpendicularImpulse [ ^ perpendicularImpulse ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> perpendicularImpulse: aNumber [ perpendicularImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> angularImpulse [ ^ angularImpulse ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> angularImpulse: aNumber [ angularImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> springImpulse [ ^ springImpulse ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> springImpulse: aNumber [ springImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> lowerLimitImpulse [ ^ lowerLimitImpulse ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> lowerLimitImpulse: aNumber [ lowerLimitImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> upperLimitImpulse [ ^ upperLimitImpulse ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> upperLimitImpulse: aNumber [ upperLimitImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> motorImpulse [ ^ motorImpulse ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> motorImpulse: aNumber [ motorImpulse := aNumber asFloat ]

{ #category : 'private' }
CFPhysicsPrismaticJoint >> resetAxialImpulses [ springImpulse := 0.0. lowerLimitImpulse := 0.0. upperLimitImpulse := 0.0. motorImpulse := 0.0 ]
{ #category : 'private' }
CFPhysicsPrismaticJoint >> resetPerpendicularImpulse [ perpendicularImpulse := 0.0 ]

{ #category : 'testing' }
CFPhysicsPrismaticJoint >> includesBody: aBody [ ^ endpointPair includesBody: aBody ]
{ #category : 'testing' }
CFPhysicsPrismaticJoint >> includesAnchor: anAnchor [ ^ endpointPair anchorA == anAnchor or: [ endpointPair anchorB == anAnchor ] ]

{ #category : 'capturing' }
CFPhysicsPrismaticJoint >> capturedForStep [
	| captured |
	captured := self shallowCopy.
	captured endpointPair: (CFPhysicsCapturedEndpointPair from: endpointPair); sourceJoint: self.
	^ captured
]

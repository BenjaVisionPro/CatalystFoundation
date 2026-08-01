"
I represent a joint that preserves the relative transform of two bodies.

My responsibility is to retain its reference relationship and accumulated linear and angular impulses.
"
Class {
	#name : 'CFPhysicsWeldJoint',
	#superclass : 'CFPhysicsJoint',
	#instVars : [ 'endpointPair', 'accumulatedImpulse', 'referenceAngle', 'accumulatedAngularImpulse', 'linearHertz', 'linearDampingRatio', 'angularHertz', 'angularDampingRatio' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsWeldJoint class >> between: bodyA and: bodyB [
	^ self
		betweenAnchor: (CFPhysicsBodyCentreAnchor on: bodyA)
		andAnchor: (CFPhysicsBodyCentreAnchor on: bodyB)
]

{ #category : 'instance creation' }
CFPhysicsWeldJoint class >> betweenAnchor: anchorA andAnchor: anchorB [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair
		anchorA: anchorA
		anchorB: anchorB)
]

{ #category : 'instance creation' }
CFPhysicsWeldJoint class >> betweenEndpoints: anEndpointPair [
	^ self new
		endpointPair: anEndpointPair;
		referenceAngle: ((self angleFor: anEndpointPair bodyB) - (self angleFor: anEndpointPair bodyA));
		yourself
]

{ #category : 'private' }
CFPhysicsWeldJoint class >> angleFor: aBody [
	^ aBody ifNil: [ 0.0 ] ifNotNil: [ aBody rotation ]
]

{ #category : 'initialization' }
CFPhysicsWeldJoint >> initialize [
	super initialize.
	accumulatedImpulse := 0 @ 0.
	referenceAngle := 0.0.
	accumulatedAngularImpulse := 0.0.
	linearHertz := 0.0.
	linearDampingRatio := 0.0.
	angularHertz := 0.0.
	angularDampingRatio := 0.0
]

{ #category : 'accessing' }
CFPhysicsWeldJoint >> endpointPair [ ^ endpointPair ]
{ #category : 'accessing' }
CFPhysicsWeldJoint >> endpointPair: anEndpointPair [ endpointPair := anEndpointPair ]
{ #category : 'accessing' }
CFPhysicsWeldJoint >> anchorA [ ^ endpointPair anchorA ]
{ #category : 'accessing' }
CFPhysicsWeldJoint >> anchorB [ ^ endpointPair anchorB ]
{ #category : 'accessing' }
CFPhysicsWeldJoint >> bodyA [ ^ endpointPair bodyA ]
{ #category : 'accessing' }
CFPhysicsWeldJoint >> bodyB [ ^ endpointPair bodyB ]

{ #category : 'solver state' }
CFPhysicsWeldJoint >> accumulatedImpulse [ ^ accumulatedImpulse ]
{ #category : 'solver state' }
CFPhysicsWeldJoint >> accumulatedImpulse: aPoint [ accumulatedImpulse := aPoint ]

{ #category : 'configuration' }
CFPhysicsWeldJoint >> referenceAngle [ ^ referenceAngle ]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> referenceAngle: aNumber [
	referenceAngle := aNumber asFloat.
	accumulatedAngularImpulse := 0.0.
	self wakeBodies
]


{ #category : 'configuration' }
CFPhysicsWeldJoint >> linearHertz [ ^ linearHertz ]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> linearHertz: aNumber [
	self assert: (aNumber >= 0.0).
	linearHertz := aNumber asFloat.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> linearDampingRatio [ ^ linearDampingRatio ]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> linearDampingRatio: aNumber [
	self assert: (aNumber >= 0.0).
	linearDampingRatio := aNumber asFloat.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> angularHertz [ ^ angularHertz ]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> angularHertz: aNumber [
	self assert: (aNumber >= 0.0).
	angularHertz := aNumber asFloat.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> angularDampingRatio [ ^ angularDampingRatio ]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> angularDampingRatio: aNumber [
	self assert: (aNumber >= 0.0).
	angularDampingRatio := aNumber asFloat.
	self wakeBodies
]

{ #category : 'solver state' }
CFPhysicsWeldJoint >> accumulatedAngularImpulse [ ^ accumulatedAngularImpulse ]

{ #category : 'configuration' }
CFPhysicsWeldJoint >> linearHertz [ ^ linearHertz ]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> linearHertz: aNumber [
	self assert: (aNumber >= 0.0).
	linearHertz := aNumber asFloat.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> linearDampingRatio [ ^ linearDampingRatio ]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> linearDampingRatio: aNumber [
	self assert: (aNumber >= 0.0).
	linearDampingRatio := aNumber asFloat.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> angularHertz [ ^ angularHertz ]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> angularHertz: aNumber [
	self assert: (aNumber >= 0.0).
	angularHertz := aNumber asFloat.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> angularDampingRatio [ ^ angularDampingRatio ]
{ #category : 'configuration' }
CFPhysicsWeldJoint >> angularDampingRatio: aNumber [
	self assert: (aNumber >= 0.0).
	angularDampingRatio := aNumber asFloat.
	self wakeBodies
]

{ #category : 'solver state' }
CFPhysicsWeldJoint >> accumulatedAngularImpulse: aNumber [ accumulatedAngularImpulse := aNumber asFloat ]

{ #category : 'testing' }
CFPhysicsWeldJoint >> includesBody: aBody [ ^ endpointPair includesBody: aBody ]

{ #category : 'testing' }
CFPhysicsWeldJoint >> includesAnchor: anAnchor [
	(endpointPair respondsTo: #anchorA) ifFalse: [ ^ false ].
	^ endpointPair anchorA == anAnchor or: [ endpointPair anchorB == anAnchor ]
]

{ #category : 'capturing' }
CFPhysicsWeldJoint >> capturedForStep [
	| captured |
	captured := self shallowCopy.
	captured
		endpointPair: (CFPhysicsCapturedEndpointPair from: endpointPair);
		sourceJoint: self.
	^ captured
]

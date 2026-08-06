"
I represent a Box2D 3.1.1 distance joint between two anchors.

My responsibility is to retain the target length, optional spring, length-range limit, axial motor configuration and accumulated impulses across solver steps.
"
Class {
	#name : 'CFPhysicsDistanceJoint',
	#superclass : 'CFPhysicsJoint',
	#instVars : [ 'endpointPair', 'length', 'springEnabled', 'hertz', 'dampingRatio', 'limitsEnabled', 'minimumLength', 'maximumLength', 'motorEnabled', 'maximumMotorForce', 'motorSpeed', 'impulse', 'lowerLimitImpulse', 'upperLimitImpulse', 'motorImpulse' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsDistanceJoint class >> between: bodyA and: bodyB [
	^ self betweenAnchor: (CFPhysicsBodyCentreAnchor on: bodyA) andAnchor: (CFPhysicsBodyCentreAnchor on: bodyB)
]

{ #category : 'instance creation' }
CFPhysicsDistanceJoint class >> betweenAnchor: anchorA andAnchor: anchorB [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair anchorA: anchorA anchorB: anchorB)
]

{ #category : 'instance creation' }
CFPhysicsDistanceJoint class >> betweenEndpoints: endpoints [
	^ self new
		endpointPair: endpoints;
		initialLength: (self distanceBetweenEndpoints: endpoints);
		yourself
]

{ #category : 'private' }
CFPhysicsDistanceJoint class >> distanceBetweenEndpoints: endpoints [
	| points |
	points := endpoints worldPoints.
	^ (points second - points first) r
]

{ #category : 'initialization' }
CFPhysicsDistanceJoint >> initialize [
	super initialize.
	length := 1.0.
	springEnabled := false.
	hertz := 0.0.
	dampingRatio := 0.0.
	limitsEnabled := false.
	minimumLength := 0.0.
	maximumLength := Float infinity.
	motorEnabled := false.
	maximumMotorForce := 0.0.
	motorSpeed := 0.0.
	impulse := 0.0.
	lowerLimitImpulse := 0.0.
	upperLimitImpulse := 0.0.
	motorImpulse := 0.0
]

{ #category : 'accessing' }
CFPhysicsDistanceJoint >> endpointPair [ ^ endpointPair ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> endpointPair: endpoints [ endpointPair := endpoints ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> anchorA [ ^ endpointPair anchorA ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> anchorB [ ^ endpointPair anchorB ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> bodyA [ ^ endpointPair bodyA ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> bodyB [ ^ endpointPair bodyB ]

{ #category : 'private - initialization' }
CFPhysicsDistanceJoint >> initialLength: aNumber [
	length := aNumber asFloat max: 0.0
]

{ #category : 'configuration' }
CFPhysicsDistanceJoint >> length [ ^ length ]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> currentLength [
	^ (endpointPair worldPointB - endpointPair worldPointA) r
]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> length: aNumber [
	| newLength |
	newLength := aNumber asFloat max: 0.0001.
	length = newLength ifTrue: [ ^ self ].
	length := newLength.
	self resetLengthImpulses.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> springEnabled [ ^ springEnabled ]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> springEnabled: aBoolean [
	springEnabled = aBoolean ifTrue: [ ^ self ].
	springEnabled := aBoolean.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> hertz [ ^ hertz ]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> hertz: aNumber [
	| newHertz |
	newHertz := aNumber asFloat max: 0.0.
	hertz = newHertz ifTrue: [ ^ self ].
	hertz := newHertz.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> dampingRatio [ ^ dampingRatio ]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> dampingRatio: aNumber [
	| newDampingRatio |
	newDampingRatio := aNumber asFloat max: 0.0.
	dampingRatio = newDampingRatio ifTrue: [ ^ self ].
	dampingRatio := newDampingRatio.
	self wakeBodies
]

{ #category : 'limits' }
CFPhysicsDistanceJoint >> limitsEnabled [ ^ limitsEnabled ]
{ #category : 'limits' }
CFPhysicsDistanceJoint >> limitsEnabled: aBoolean [
	limitsEnabled = aBoolean ifTrue: [ ^ self ].
	limitsEnabled := aBoolean.
	self wakeBodies
]
{ #category : 'limits' }
CFPhysicsDistanceJoint >> minimumLength [ ^ minimumLength ]
{ #category : 'limits' }
CFPhysicsDistanceJoint >> maximumLength [ ^ maximumLength ]
{ #category : 'limits' }
CFPhysicsDistanceJoint >> limitLengthFrom: minimum to: maximum [
	| resolvedMinimum resolvedMaximum |
	resolvedMinimum := minimum asFloat max: 0.0001.
	resolvedMaximum := maximum asFloat max: 0.0001.
	minimumLength := resolvedMinimum min: resolvedMaximum.
	maximumLength := resolvedMinimum max: resolvedMaximum.
	self resetLengthImpulses.
	self wakeBodies
]

{ #category : 'motor' }
CFPhysicsDistanceJoint >> motorEnabled [ ^ motorEnabled ]
{ #category : 'motor' }
CFPhysicsDistanceJoint >> motorEnabled: aBoolean [
	motorEnabled = aBoolean ifTrue: [ ^ self ].
	motorEnabled := aBoolean.
	motorImpulse := 0.0.
	self wakeBodies
]
{ #category : 'motor' }
CFPhysicsDistanceJoint >> maximumMotorForce [ ^ maximumMotorForce ]
{ #category : 'motor' }
CFPhysicsDistanceJoint >> maximumMotorForce: aNumber [
	maximumMotorForce := aNumber asFloat max: 0.0.
	self wakeBodies
]
{ #category : 'motor' }
CFPhysicsDistanceJoint >> motorSpeed [ ^ motorSpeed ]
{ #category : 'motor' }
CFPhysicsDistanceJoint >> motorSpeed: aNumber [
	motorSpeed := aNumber asFloat.
	self wakeBodies
]

{ #category : 'solver state' }
CFPhysicsDistanceJoint >> impulse [ ^ impulse ]
{ #category : 'solver state' }
CFPhysicsDistanceJoint >> impulse: aNumber [ impulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsDistanceJoint >> lowerLimitImpulse [ ^ lowerLimitImpulse ]
{ #category : 'solver state' }
CFPhysicsDistanceJoint >> lowerLimitImpulse: aNumber [ lowerLimitImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsDistanceJoint >> upperLimitImpulse [ ^ upperLimitImpulse ]
{ #category : 'solver state' }
CFPhysicsDistanceJoint >> upperLimitImpulse: aNumber [ upperLimitImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsDistanceJoint >> motorImpulse [ ^ motorImpulse ]
{ #category : 'solver state' }
CFPhysicsDistanceJoint >> motorImpulse: aNumber [ motorImpulse := aNumber asFloat ]

{ #category : 'private' }
CFPhysicsDistanceJoint >> resetLengthImpulses [
	impulse := 0.0.
	lowerLimitImpulse := 0.0.
	upperLimitImpulse := 0.0
]

{ #category : 'testing' }
CFPhysicsDistanceJoint >> includesBody: aBody [ ^ endpointPair includesBody: aBody ]
{ #category : 'testing' }
CFPhysicsDistanceJoint >> includesAnchor: anAnchor [
	^ endpointPair anchorA == anAnchor or: [ endpointPair anchorB == anAnchor ]
]

{ #category : 'capturing' }
CFPhysicsDistanceJoint >> capturedForStep [
	| captured |
	captured := self shallowCopy.
	captured endpointPair: (CFPhysicsCapturedEndpointPair from: endpointPair); sourceJoint: self.
	^ captured
]

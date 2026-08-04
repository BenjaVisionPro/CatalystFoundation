"
I represent a Box2D-compatible mouse joint.

My responsibility is to drive a body-local anchor toward a world-space target through the joint solver.
"
Class {
	#name : 'CFPhysicsMouseJoint',
	#superclass : 'CFPhysicsJoint',
	#instVars : [ 'bodyB', 'localAnchorB', 'target', 'hertz', 'dampingRatio', 'maximumForce', 'linearImpulse', 'angularImpulse' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsMouseJoint class >> body: aBody target: aPoint [
	^ self new
		bodyB: aBody;
		target: aPoint;
		localAnchorB: (aBody bodyLocalPointForWorldPoint: aPoint);
		yourself
]

{ #category : 'initialization' }
CFPhysicsMouseJoint >> initialize [
	super initialize.
	hertz := 4.0.
	dampingRatio := 1.0.
	maximumForce := 1.0.
	linearImpulse := 0 @ 0.
	angularImpulse := 0.0
]

{ #category : 'accessing' }
CFPhysicsMouseJoint >> bodyA [ ^ nil ]
{ #category : 'accessing' }
CFPhysicsMouseJoint >> bodyB [ ^ bodyB ]
{ #category : 'accessing' }
CFPhysicsMouseJoint >> bodyB: aBody [ bodyB := aBody ]
{ #category : 'accessing' }
CFPhysicsMouseJoint >> localAnchorB [ ^ localAnchorB ]
{ #category : 'accessing' }
CFPhysicsMouseJoint >> localAnchorB: aPoint [ localAnchorB := aPoint ]
{ #category : 'configuration' }
CFPhysicsMouseJoint >> target [ ^ target ]
{ #category : 'configuration' }
CFPhysicsMouseJoint >> target: aPoint [
	target = aPoint ifTrue: [ ^ self ].
	target := aPoint.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsMouseJoint >> hertz [ ^ hertz ]
{ #category : 'configuration' }
CFPhysicsMouseJoint >> hertz: aNumber [
	hertz := aNumber asFloat max: 0.0.
	linearImpulse := 0 @ 0.
	angularImpulse := 0.0.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsMouseJoint >> dampingRatio [ ^ dampingRatio ]
{ #category : 'configuration' }
CFPhysicsMouseJoint >> dampingRatio: aNumber [
	dampingRatio := aNumber asFloat max: 0.0.
	linearImpulse := 0 @ 0.
	angularImpulse := 0.0.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsMouseJoint >> maximumForce [ ^ maximumForce ]
{ #category : 'configuration' }
CFPhysicsMouseJoint >> maximumForce: aNumber [
	maximumForce := aNumber asFloat max: 0.0.
	self wakeBodies
]
{ #category : 'solver state' }
CFPhysicsMouseJoint >> linearImpulse [ ^ linearImpulse ]
{ #category : 'solver state' }
CFPhysicsMouseJoint >> linearImpulse: aPoint [ linearImpulse := aPoint ]
{ #category : 'solver state' }
CFPhysicsMouseJoint >> angularImpulse [ ^ angularImpulse ]
{ #category : 'solver state' }
CFPhysicsMouseJoint >> angularImpulse: aNumber [ angularImpulse := aNumber ]
{ #category : 'testing' }
CFPhysicsMouseJoint >> includesBody: aBody [ ^ bodyB == aBody ]
{ #category : 'testing' }
CFPhysicsMouseJoint >> includesAnchor: anAnchor [ ^ false ]
{ #category : 'capturing' }
CFPhysicsMouseJoint >> capturedForStep [
	| captured |
	captured := self shallowCopy.
	captured sourceJoint: self.
	^ captured
]

"
I represent a Box2D 3.1.1 motor joint.

My responsibility is to control the relative position and angle of two bodies using capped linear and angular impulses.
"
Class {
	#name : 'CFPhysicsMotorJoint',
	#superclass : 'CFPhysicsJoint',
	#instVars : [ 'bodyA', 'bodyB', 'linearOffset', 'angularOffset', 'maximumForce', 'maximumTorque', 'correctionFactor', 'linearImpulse', 'angularImpulse' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsMotorJoint class >> between: bodyA and: bodyB [
	^ self new
		bodyA: bodyA;
		bodyB: bodyB;
		initialLinearOffset: bodyB worldBodyOrigin - bodyA worldBodyOrigin
			angularOffset: bodyB rotation - bodyA rotation;
		yourself
]

{ #category : 'initialization' }
CFPhysicsMotorJoint >> initialize [
	super initialize.
	linearOffset := 0 @ 0.
	angularOffset := 0.0.
	maximumForce := 1.0.
	maximumTorque := 1.0.
	correctionFactor := 0.3.
	linearImpulse := 0 @ 0.
	angularImpulse := 0.0
]

{ #category : 'private - initialization' }
CFPhysicsMotorJoint >> initialLinearOffset: aPoint angularOffset: aNumber [
	linearOffset := aPoint.
	angularOffset := aNumber asFloat
]

{ #category : 'accessing' }
CFPhysicsMotorJoint >> bodyA [ ^ bodyA ]
{ #category : 'accessing' }
CFPhysicsMotorJoint >> bodyA: aBody [ bodyA := aBody ]
{ #category : 'accessing' }
CFPhysicsMotorJoint >> bodyB [ ^ bodyB ]
{ #category : 'accessing' }
CFPhysicsMotorJoint >> bodyB: aBody [ bodyB := aBody ]
{ #category : 'configuration' }
CFPhysicsMotorJoint >> linearOffset [ ^ linearOffset ]
{ #category : 'configuration' }
CFPhysicsMotorJoint >> linearOffset: aPoint [ linearOffset := aPoint. self wakeBodies ]
{ #category : 'configuration' }
CFPhysicsMotorJoint >> angularOffset [ ^ angularOffset ]
{ #category : 'configuration' }
CFPhysicsMotorJoint >> angularOffset: aNumber [ angularOffset := aNumber asFloat. self wakeBodies ]
{ #category : 'configuration' }
CFPhysicsMotorJoint >> maximumForce [ ^ maximumForce ]
{ #category : 'configuration' }
CFPhysicsMotorJoint >> maximumForce: aNumber [ maximumForce := aNumber asFloat max: 0.0. self wakeBodies ]
{ #category : 'configuration' }
CFPhysicsMotorJoint >> maximumTorque [ ^ maximumTorque ]
{ #category : 'configuration' }
CFPhysicsMotorJoint >> maximumTorque: aNumber [ maximumTorque := aNumber asFloat max: 0.0. self wakeBodies ]
{ #category : 'configuration' }
CFPhysicsMotorJoint >> correctionFactor [ ^ correctionFactor ]
{ #category : 'configuration' }
CFPhysicsMotorJoint >> correctionFactor: aNumber [ correctionFactor := aNumber asFloat max: 0.0 min: 1.0. self wakeBodies ]
{ #category : 'solver state' }
CFPhysicsMotorJoint >> linearImpulse [ ^ linearImpulse ]
{ #category : 'solver state' }
CFPhysicsMotorJoint >> linearImpulse: aPoint [ linearImpulse := aPoint ]
{ #category : 'solver state' }
CFPhysicsMotorJoint >> angularImpulse [ ^ angularImpulse ]
{ #category : 'solver state' }
CFPhysicsMotorJoint >> angularImpulse: aNumber [ angularImpulse := aNumber ]
{ #category : 'testing' }
CFPhysicsMotorJoint >> includesBody: aBody [ ^ bodyA == aBody or: [ bodyB == aBody ] ]
{ #category : 'testing' }
CFPhysicsMotorJoint >> includesAnchor: anAnchor [ ^ false ]
{ #category : 'capturing' }
CFPhysicsMotorJoint >> capturedForStep [ | captured | captured := self shallowCopy. captured sourceJoint: self. ^ captured ]

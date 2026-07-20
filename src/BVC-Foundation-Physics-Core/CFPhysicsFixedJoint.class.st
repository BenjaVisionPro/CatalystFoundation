Class {
	#name : 'CFPhysicsFixedJoint',
	#superclass : 'CFPhysicsRevoluteJoint',
	#instVars : [ 'referenceAngle', 'accumulatedAngularImpulse' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsFixedJoint class >> between: firstBodyState and: secondBodyState [
	^ self
		betweenAnchor: (CFPhysicsBodyCentreAnchor on: firstBodyState)
		andAnchor: (CFPhysicsBodyCentreAnchor on: secondBodyState)
]

{ #category : 'instance creation' }
CFPhysicsFixedJoint class >> betweenAnchor: firstAnchor andAnchor: secondAnchor [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair
		anchorA: firstAnchor
		anchorB: secondAnchor)
]

{ #category : 'instance creation' }
CFPhysicsFixedJoint class >> betweenEndpoints: anEndpointPair [
	^ self new
		endpointPair: anEndpointPair;
		referenceAngle: ((self angleFor: anEndpointPair bodyB) - (self angleFor: anEndpointPair bodyA));
		yourself
]

{ #category : 'private' }
CFPhysicsFixedJoint class >> angleFor: aBody [
	^ aBody ifNil: [ 0.0 ] ifNotNil: [ aBody rotation ]
]

{ #category : 'initialization' }
CFPhysicsFixedJoint >> initialize [
	super initialize.
	referenceAngle := 0.0.
	accumulatedAngularImpulse := 0.0
]

{ #category : 'configuration' }
CFPhysicsFixedJoint >> referenceAngle [ ^ referenceAngle ]
{ #category : 'configuration' }
CFPhysicsFixedJoint >> referenceAngle: aNumber [
	referenceAngle := aNumber asFloat.
	accumulatedAngularImpulse := 0.0.
	self wakeBodies
]

{ #category : 'solver state' }
CFPhysicsFixedJoint >> accumulatedAngularImpulse [ ^ accumulatedAngularImpulse ]
{ #category : 'solver state' }
CFPhysicsFixedJoint >> accumulatedAngularImpulse: aNumber [ accumulatedAngularImpulse := aNumber asFloat ]

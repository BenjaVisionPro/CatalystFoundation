Class {
	#name : 'CFPhysicsFixedJoint',
	#superclass : 'CFPhysicsRevoluteJoint',
	#instVars : [ 'accumulatedAngularImpulse' ],
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

{ #category : 'initialization' }
CFPhysicsFixedJoint >> initialize [
	super initialize.
	accumulatedAngularImpulse := 0.0
]

{ #category : 'configuration' }
CFPhysicsFixedJoint >> referenceAngle: aNumber [
	super referenceAngle: aNumber.
	accumulatedAngularImpulse := 0.0
]

{ #category : 'solver state' }
CFPhysicsFixedJoint >> accumulatedAngularImpulse [ ^ accumulatedAngularImpulse ]
{ #category : 'solver state' }
CFPhysicsFixedJoint >> accumulatedAngularImpulse: aNumber [ accumulatedAngularImpulse := aNumber asFloat ]

"
I represent two related endpoints in a Physics world.

My responsibility is to provide their bodies and current world points to constraints and joints.
"
Class {
	#name : 'CFPhysicsEndpointPair',
	#superclass : 'Object',
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'accessing' }
CFPhysicsEndpointPair >> bodyA [
	self subclassResponsibility
]

{ #category : 'accessing' }
CFPhysicsEndpointPair >> bodyB [
	self subclassResponsibility
]



{ #category : 'accessing' }
CFPhysicsEndpointPair >> world [
	self subclassResponsibility
]

{ #category : 'geometry' }
CFPhysicsEndpointPair >> worldPoints [
	self subclassResponsibility
]

{ #category : 'geometry' }
CFPhysicsEndpointPair >> worldPointA [
	^ self worldPoints first
]

{ #category : 'geometry' }
CFPhysicsEndpointPair >> worldPointB [
	^ self worldPoints second
]

{ #category : 'testing' }
CFPhysicsEndpointPair >> includesBody: aBodyState [
	^ (self bodyA notNil and: [ self bodyA == aBodyState ])
		or: [ self bodyB notNil and: [ self bodyB == aBodyState ] ]
]


{ #category : 'relationships' }
CFPhysicsEndpointPair >> distanceJoint [
	^ self world addJoint: (CFPhysicsDistanceJoint betweenEndpoints: self)
]

{ #category : 'relationships' }
CFPhysicsEndpointPair >> revoluteJoint [
	^ self world addJoint: (CFPhysicsRevoluteJoint betweenEndpoints: self)
]

{ #category : 'relationships' }
CFPhysicsEndpointPair >> weldJoint [
	^ self world addJoint: (CFPhysicsWeldJoint betweenEndpoints: self)
]

{ #category : 'relationships' }
CFPhysicsEndpointPair >> attraction [
	^ self world addForce: (CFPhysicsAttractionForce betweenEndpoints: self)
]

{ #category : 'relationships' }
CFPhysicsEndpointPair >> repulsion [
	^ self world addForce: (CFPhysicsRepulsionForce betweenEndpoints: self)
]

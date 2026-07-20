Class {
	#name : 'CFPhysicsEndpointPair',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
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
CFPhysicsEndpointPair >> spring [
	^ self world addSpringConstraint: (CFPhysicsSpringConstraint betweenEndpoints: self)
]

{ #category : 'relationships' }
CFPhysicsEndpointPair >> distanceJoint [
	^ self world addDistanceJoint: (CFPhysicsDistanceJoint betweenEndpoints: self)
]

{ #category : 'relationships' }
CFPhysicsEndpointPair >> revoluteJoint [
	^ self world addRevoluteJoint: (CFPhysicsRevoluteJoint betweenEndpoints: self)
]

{ #category : 'relationships' }
CFPhysicsEndpointPair >> fixedJoint [
	^ self world addFixedJoint: (CFPhysicsFixedJoint betweenEndpoints: self)
]

{ #category : 'relationships' }
CFPhysicsEndpointPair >> attraction [
	^ self world addAttractionConstraint: (CFPhysicsAttractionConstraint betweenEndpoints: self)
]

{ #category : 'relationships' }
CFPhysicsEndpointPair >> repulsion [
	^ self world addRepulsionConstraint: (CFPhysicsRepulsionConstraint betweenEndpoints: self)
]

Class {
	#name : 'CFPhysicsEndpointPair',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
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

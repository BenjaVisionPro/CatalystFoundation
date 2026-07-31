Class {
	#name : 'CFPhysicsCapturedEndpointPair',
	#superclass : 'CFPhysicsEndpointPair',
	#instVars : [ 'bodyA', 'bodyB', 'worldPointA', 'worldPointB' ],
	#category : 'BVC-Physics-Core',
	#package : 'BVC-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsCapturedEndpointPair class >> from: anEndpointPair [
	^ self new
		bodyA: anEndpointPair bodyA;
		bodyB: anEndpointPair bodyB;
		worldPointA: anEndpointPair worldPointA;
		worldPointB: anEndpointPair worldPointB;
		yourself
]

{ #category : 'accessing' }
CFPhysicsCapturedEndpointPair >> bodyA [ ^ bodyA ]

{ #category : 'accessing' }
CFPhysicsCapturedEndpointPair >> bodyA: aBody [ bodyA := aBody ]

{ #category : 'accessing' }
CFPhysicsCapturedEndpointPair >> bodyB [ ^ bodyB ]

{ #category : 'accessing' }
CFPhysicsCapturedEndpointPair >> bodyB: aBody [ bodyB := aBody ]

{ #category : 'geometry' }
CFPhysicsCapturedEndpointPair >> worldPointA [ ^ worldPointA ]

{ #category : 'geometry' }
CFPhysicsCapturedEndpointPair >> worldPointA: aPoint [ worldPointA := aPoint ]

{ #category : 'geometry' }
CFPhysicsCapturedEndpointPair >> worldPointB [ ^ worldPointB ]

{ #category : 'geometry' }
CFPhysicsCapturedEndpointPair >> worldPointB: aPoint [ worldPointB := aPoint ]

{ #category : 'geometry' }
CFPhysicsCapturedEndpointPair >> worldPoints [ ^ { worldPointA. worldPointB } ]

{ #category : 'accessing' }
CFPhysicsCapturedEndpointPair >> world [ ^ nil ]

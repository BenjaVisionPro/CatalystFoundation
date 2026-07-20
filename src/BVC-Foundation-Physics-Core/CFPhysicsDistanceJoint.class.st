Class {
	#name : 'CFPhysicsDistanceJoint',
	#superclass : 'Object',
	#instVars : [ 'endpointPair', 'restLength', 'active', 'sequence', 'accumulatedImpulse', 'collideConnected' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsDistanceJoint class >> between: firstBodyState and: secondBodyState [
	^ self
		betweenAnchor: (CFPhysicsBodyCentreAnchor on: firstBodyState)
		andAnchor: (CFPhysicsBodyCentreAnchor on: secondBodyState)
]

{ #category : 'instance creation' }
CFPhysicsDistanceJoint class >> betweenAnchor: firstAnchor andAnchor: secondAnchor [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair
		anchorA: firstAnchor
		anchorB: secondAnchor)
]

{ #category : 'instance creation' }
CFPhysicsDistanceJoint class >> betweenEndpoints: anEndpointPair [
	^ self new
		endpointPair: anEndpointPair;
		restLength: (self distanceBetweenEndpoints: anEndpointPair);
		yourself
]

{ #category : 'private' }
CFPhysicsDistanceJoint class >> distanceBetweenEndpoints: anEndpointPair [
	| points |
	points := anEndpointPair worldPoints.
	^ (points second - points first) r
]

{ #category : 'initialization' }
CFPhysicsDistanceJoint >> initialize [
	super initialize.
	restLength := 0.0.
	active := true.
	sequence := 0.
	accumulatedImpulse := 0.0.
	collideConnected := true
]

{ #category : 'accessing' }
CFPhysicsDistanceJoint >> endpointPair [ ^ endpointPair ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> endpointPair: anEndpointPair [ endpointPair := anEndpointPair ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> anchorA [ ^ endpointPair anchorA ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> anchorB [ ^ endpointPair anchorB ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> bodyA [ ^ endpointPair bodyA ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> bodyB [ ^ endpointPair bodyB ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> firstBody [ ^ self bodyA ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> secondBody [ ^ self bodyB ]

{ #category : 'configuration' }
CFPhysicsDistanceJoint >> restLength [ ^ restLength ]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> restLength: aNumber [
	restLength := aNumber asFloat max: 0.0.
	accumulatedImpulse := 0.0.
	self wakeBodies
]
{ #category : 'solver state' }
CFPhysicsDistanceJoint >> accumulatedImpulse [ ^ accumulatedImpulse ]
{ #category : 'solver state' }
CFPhysicsDistanceJoint >> accumulatedImpulse: aNumber [ accumulatedImpulse := aNumber asFloat ]

{ #category : 'configuration' }
CFPhysicsDistanceJoint >> collideConnected [ ^ collideConnected ]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> collideConnected: aBoolean [ collideConnected := aBoolean ]

{ #category : 'ordering' }
CFPhysicsDistanceJoint >> sequence [ ^ sequence ]
{ #category : 'ordering' }
CFPhysicsDistanceJoint >> sequence: anInteger [ sequence := anInteger ]
{ #category : 'ordering' }
CFPhysicsDistanceJoint >> orderingKey [ ^ sequence ]

{ #category : 'testing' }
CFPhysicsDistanceJoint >> isActive [ ^ active ]
{ #category : 'testing' }
CFPhysicsDistanceJoint >> includesBody: aBodyState [ ^ endpointPair includesBody: aBodyState ]

{ #category : 'testing' }
CFPhysicsDistanceJoint >> includesAnchor: anAnchor [
	(endpointPair respondsTo: #anchorA) ifFalse: [ ^ false ].
	^ endpointPair anchorA == anAnchor or: [ endpointPair anchorB == anAnchor ]
]

{ #category : 'waking' }
CFPhysicsDistanceJoint >> wakeBodies [
	self firstBody ifNotNil: [ :body | body wake ].
	self secondBody ifNotNil: [ :body | body wake ]
]

{ #category : 'controlling' }
CFPhysicsDistanceJoint >> release [ active := false ]

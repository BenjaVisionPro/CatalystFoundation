Class {
	#name : 'CFPhysicsRevoluteJoint',
	#superclass : 'Object',
	#instVars : [ 'endpointPair', 'active', 'sequence', 'accumulatedImpulse' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsRevoluteJoint class >> between: firstBodyState and: secondBodyState [
	^ self
		betweenAnchor: (CFPhysicsBodyCentreAnchor on: firstBodyState)
		andAnchor: (CFPhysicsBodyCentreAnchor on: secondBodyState)
]

{ #category : 'instance creation' }
CFPhysicsRevoluteJoint class >> betweenAnchor: firstAnchor andAnchor: secondAnchor [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair
		anchorA: firstAnchor
		anchorB: secondAnchor)
]

{ #category : 'instance creation' }
CFPhysicsRevoluteJoint class >> betweenEndpoints: anEndpointPair [
	^ self new
		endpointPair: anEndpointPair;
		yourself
]

{ #category : 'initialization' }
CFPhysicsRevoluteJoint >> initialize [
	super initialize.
	active := true.
	sequence := 0.
	accumulatedImpulse := 0 @ 0
]

{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> endpointPair [ ^ endpointPair ]
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> endpointPair: anEndpointPair [ endpointPair := anEndpointPair ]
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> anchorA [ ^ endpointPair anchorA ]
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> anchorB [ ^ endpointPair anchorB ]
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> bodyA [ ^ endpointPair bodyA ]
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> bodyB [ ^ endpointPair bodyB ]
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> firstBody [ ^ self bodyA ]
{ #category : 'accessing' }
CFPhysicsRevoluteJoint >> secondBody [ ^ self bodyB ]

{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> accumulatedImpulse [ ^ accumulatedImpulse ]
{ #category : 'solver state' }
CFPhysicsRevoluteJoint >> accumulatedImpulse: aPoint [ accumulatedImpulse := aPoint ]

{ #category : 'ordering' }
CFPhysicsRevoluteJoint >> sequence [ ^ sequence ]
{ #category : 'ordering' }
CFPhysicsRevoluteJoint >> sequence: anInteger [ sequence := anInteger ]
{ #category : 'ordering' }
CFPhysicsRevoluteJoint >> orderingKey [ ^ sequence ]

{ #category : 'testing' }
CFPhysicsRevoluteJoint >> isActive [ ^ active ]
{ #category : 'testing' }
CFPhysicsRevoluteJoint >> includesBody: aBodyState [ ^ endpointPair includesBody: aBodyState ]

{ #category : 'testing' }
CFPhysicsRevoluteJoint >> includesAnchor: anAnchor [
	(endpointPair respondsTo: #anchorA) ifFalse: [ ^ false ].
	^ endpointPair anchorA == anAnchor or: [ endpointPair anchorB == anAnchor ]
]

{ #category : 'waking' }
CFPhysicsRevoluteJoint >> wakeBodies [
	self firstBody ifNotNil: [ :body | body wake ].
	self secondBody ifNotNil: [ :body | body wake ]
]

{ #category : 'controlling' }
CFPhysicsRevoluteJoint >> release [ active := false ]

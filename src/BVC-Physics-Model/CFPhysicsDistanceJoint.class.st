"
I represent a joint that maintains a target distance between two anchors.

My responsibility is to retain its configuration and accumulated solver state across steps.
"
Class {
	#name : 'CFPhysicsDistanceJoint',
	#superclass : 'CFPhysicsJoint',
	#instVars : [ 'endpointPair', 'restLength', 'accumulatedImpulse' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
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
	accumulatedImpulse := 0.0.
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



{ #category : 'testing' }
CFPhysicsDistanceJoint >> includesBody: aBodyState [ ^ endpointPair includesBody: aBodyState ]

{ #category : 'testing' }
CFPhysicsDistanceJoint >> includesAnchor: anAnchor [
	(endpointPair respondsTo: #anchorA) ifFalse: [ ^ false ].
	^ endpointPair anchorA == anAnchor or: [ endpointPair anchorB == anAnchor ]
]




{ #category : 'capturing' }
CFPhysicsDistanceJoint >> capturedForStep [
	| captured |
	captured := self shallowCopy.
	captured
		endpointPair: (CFPhysicsCapturedEndpointPair from: endpointPair);
		sourceJoint: self.
	^ captured
]



"
I represent a Box2D 3.1.1 distance joint between two anchors.

My responsibility is to retain the target length, optional spring configuration and accumulated axial impulse across solver steps.
"
Class {
	#name : 'CFPhysicsDistanceJoint',
	#superclass : 'CFPhysicsJoint',
	#instVars : [ 'endpointPair', 'length', 'springEnabled', 'hertz', 'dampingRatio', 'impulse' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsDistanceJoint class >> between: bodyA and: bodyB [
	^ self betweenAnchor: (CFPhysicsBodyCentreAnchor on: bodyA) andAnchor: (CFPhysicsBodyCentreAnchor on: bodyB)
]

{ #category : 'instance creation' }
CFPhysicsDistanceJoint class >> betweenAnchor: anchorA andAnchor: anchorB [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair anchorA: anchorA anchorB: anchorB)
]

{ #category : 'instance creation' }
CFPhysicsDistanceJoint class >> betweenEndpoints: endpoints [
	^ self new endpointPair: endpoints; length: (self distanceBetweenEndpoints: endpoints); yourself
]

{ #category : 'private' }
CFPhysicsDistanceJoint class >> distanceBetweenEndpoints: endpoints [
	| points |
	points := endpoints worldPoints.
	^ (points second - points first) r
]

{ #category : 'initialization' }
CFPhysicsDistanceJoint >> initialize [
	super initialize.
	length := 1.0.
	springEnabled := false.
	hertz := 0.0.
	dampingRatio := 0.0.
	impulse := 0.0
]

{ #category : 'accessing' }
CFPhysicsDistanceJoint >> endpointPair [ ^ endpointPair ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> endpointPair: endpoints [ endpointPair := endpoints ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> anchorA [ ^ endpointPair anchorA ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> anchorB [ ^ endpointPair anchorB ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> bodyA [ ^ endpointPair bodyA ]
{ #category : 'accessing' }
CFPhysicsDistanceJoint >> bodyB [ ^ endpointPair bodyB ]

{ #category : 'configuration' }
CFPhysicsDistanceJoint >> length [ ^ length ]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> length: aNumber [
	| newLength |
	newLength := aNumber asFloat max: 0.0001.
	length = newLength ifTrue: [ ^ self ].
	length := newLength.
	impulse := 0.0.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> springEnabled [ ^ springEnabled ]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> springEnabled: aBoolean [
	springEnabled = aBoolean ifTrue: [ ^ self ].
	springEnabled := aBoolean.
	impulse := 0.0.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> hertz [ ^ hertz ]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> hertz: aNumber [
	| newHertz |
	newHertz := aNumber asFloat max: 0.0.
	hertz = newHertz ifTrue: [ ^ self ].
	hertz := newHertz.
	impulse := 0.0.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> dampingRatio [ ^ dampingRatio ]
{ #category : 'configuration' }
CFPhysicsDistanceJoint >> dampingRatio: aNumber [
	| newDampingRatio |
	newDampingRatio := aNumber asFloat max: 0.0.
	dampingRatio = newDampingRatio ifTrue: [ ^ self ].
	dampingRatio := newDampingRatio.
	impulse := 0.0.
	self wakeBodies
]

{ #category : 'solver state' }
CFPhysicsDistanceJoint >> impulse [ ^ impulse ]
{ #category : 'solver state' }
CFPhysicsDistanceJoint >> impulse: aNumber [ impulse := aNumber asFloat ]

{ #category : 'testing' }
CFPhysicsDistanceJoint >> includesBody: aBody [ ^ endpointPair includesBody: aBody ]
{ #category : 'testing' }
CFPhysicsDistanceJoint >> includesAnchor: anAnchor [
	^ endpointPair anchorA == anAnchor or: [ endpointPair anchorB == anAnchor ]
]

{ #category : 'capturing' }
CFPhysicsDistanceJoint >> capturedForStep [
	| captured |
	captured := self shallowCopy.
	captured endpointPair: (CFPhysicsCapturedEndpointPair from: endpointPair); sourceJoint: self.
	^ captured
]

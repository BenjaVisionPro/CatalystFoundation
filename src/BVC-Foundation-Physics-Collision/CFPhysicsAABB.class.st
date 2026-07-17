Class {
	#name : 'CFPhysicsAABB',
	#superclass : 'Object',
	#instVars : [ 'minimum', 'maximum' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsAABB class >> position: aPoint extent: anExtent [
	^ self new
		minimum: aPoint;
		maximum: aPoint + anExtent;
		yourself
]

{ #category : 'accessing' }
CFPhysicsAABB >> centre [
	^ (minimum + maximum) / 2.0
]

{ #category : 'accessing' }
CFPhysicsAABB >> maximum [
	^ maximum
]

{ #category : 'accessing' }
CFPhysicsAABB >> maximum: aPoint [
	maximum := aPoint
]

{ #category : 'accessing' }
CFPhysicsAABB >> minimum [
	^ minimum
]

{ #category : 'accessing' }
CFPhysicsAABB >> minimum: aPoint [
	minimum := aPoint
]

{ #category : 'collision' }
CFPhysicsAABB >> overlapWith: anotherAABB [
	| overlapX overlapY |
	overlapX := (maximum x min: anotherAABB maximum x)
		- (minimum x max: anotherAABB minimum x).
	overlapY := (maximum y min: anotherAABB maximum y)
		- (minimum y max: anotherAABB minimum y).
	^ overlapX @ overlapY
]

{ #category : 'testing' }
CFPhysicsAABB >> overlaps: anotherAABB [
	| overlap |
	overlap := self overlapWith: anotherAABB.
	^ overlap x >= 0 and: [ overlap y >= 0 ]
]

{ #category : 'accessing' }
CFPhysicsAABB >> extent [
	^ maximum - minimum
]

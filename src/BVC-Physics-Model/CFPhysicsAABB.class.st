"
I represent an axis-aligned bounding box in world coordinates.

My responsibility is to describe spatial bounds used by shapes, broad-phase queries and containment checks.
"
Class {
	#name : 'CFPhysicsAABB',
	#superclass : 'Object',
	#instVars : [ 'minimum', 'maximum' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
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

{ #category : 'combining' }
CFPhysicsAABB >> mergedWith: anotherAABB [
	| mergedMinimum mergedMaximum |
	mergedMinimum := (minimum x min: anotherAABB minimum x)
		@ (minimum y min: anotherAABB minimum y).
	mergedMaximum := (maximum x max: anotherAABB maximum x)
		@ (maximum y max: anotherAABB maximum y).
	^ CFPhysicsAABB
		position: mergedMinimum
		extent: mergedMaximum - mergedMinimum
]


{ #category : 'combining' }
CFPhysicsAABB >> expandedBy: aNumber [
	| distance |
	distance := aNumber asFloat max: 0.0.
	^ CFPhysicsAABB
		position: minimum - (distance @ distance)
		extent: self extent + ((distance * 2.0) @ (distance * 2.0))
]

{ #category : 'testing' }
CFPhysicsAABB >> contains: anotherAABB [
	^ minimum x <= anotherAABB minimum x
		and: [ minimum y <= anotherAABB minimum y
		and: [ maximum x >= anotherAABB maximum x
		and: [ maximum y >= anotherAABB maximum y ] ] ]
]

{ #category : 'measuring' }
CFPhysicsAABB >> perimeter [
	| size |
	size := self extent.
	^ 2.0 * (size x + size y)
]

{ #category : 'accessing' }
CFPhysicsAABB >> halfExtent [
	^ self extent / 2.0
]

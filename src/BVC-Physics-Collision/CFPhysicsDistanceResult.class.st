"
I describe the closest-point result for two convex shapes.

I record their separation, closest points, separating axis and whether the shapes overlap for continuous and discrete collision queries.
"
Class {
	#name : 'CFPhysicsDistanceResult',
	#superclass : 'Object',
	#instVars : [ 'distance', 'firstPoint', 'secondPoint', 'axis', 'overlapping' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsDistanceResult class >> distance: aDistance firstPoint: aFirstPoint secondPoint: aSecondPoint axis: anAxis overlapping: aBoolean [
	^ self new
		distance: aDistance;
		firstPoint: aFirstPoint;
		secondPoint: aSecondPoint;
		axis: anAxis;
		overlapping: aBoolean;
		yourself
]

{ #category : 'accessing' }
CFPhysicsDistanceResult >> distance [
	^ distance
]

{ #category : 'accessing' }
CFPhysicsDistanceResult >> distance: aNumber [
	distance := aNumber
]

{ #category : 'accessing' }
CFPhysicsDistanceResult >> firstPoint [
	^ firstPoint
]

{ #category : 'accessing' }
CFPhysicsDistanceResult >> firstPoint: aPoint [
	firstPoint := aPoint
]

{ #category : 'testing' }
CFPhysicsDistanceResult >> isOverlapping [
	^ overlapping
]

{ #category : 'testing' }
CFPhysicsDistanceResult >> isSeparated [
	^ overlapping not
]

{ #category : 'accessing' }
CFPhysicsDistanceResult >> axis [
	^ axis
]

{ #category : 'accessing' }
CFPhysicsDistanceResult >> axis: aPoint [
	axis := aPoint
]

{ #category : 'accessing' }
CFPhysicsDistanceResult >> overlapping: aBoolean [
	overlapping := aBoolean
]

{ #category : 'accessing' }
CFPhysicsDistanceResult >> secondPoint [
	^ secondPoint
]

{ #category : 'accessing' }
CFPhysicsDistanceResult >> secondPoint: aPoint [
	secondPoint := aPoint
]

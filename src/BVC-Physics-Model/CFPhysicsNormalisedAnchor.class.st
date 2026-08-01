"
I represent an anchor at a normalised point within a body's shape.

My responsibility is to preserve proportional placement when the shape's extent changes.
"
Class {
	#name : 'CFPhysicsNormalisedAnchor',
	#superclass : 'CFPhysicsAnchor',
	#instVars : [ 'normalisedPoint' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsNormalisedAnchor class >> on: aBodyState at: aPoint [
	^ self new
		body: aBodyState;
		normalisedPoint: aPoint;
		yourself
]

{ #category : 'accessing' }
CFPhysicsNormalisedAnchor >> normalisedPoint [
	^ normalisedPoint
]

{ #category : 'accessing' }
CFPhysicsNormalisedAnchor >> normalisedPoint: aPoint [
	normalisedPoint := aPoint
]

{ #category : 'geometry' }
CFPhysicsNormalisedAnchor >> worldPoint [
	^ self body
		worldPointForBodyLocalPoint:
			(self body shapeState bodyLocalPointForNormalisedPoint: normalisedPoint)
]

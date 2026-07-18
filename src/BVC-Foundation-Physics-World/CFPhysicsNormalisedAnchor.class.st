Class {
	#name : 'CFPhysicsNormalisedAnchor',
	#superclass : 'CFPhysicsAnchor',
	#instVars : [ 'normalisedPoint' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
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
	^ self body worldPointForNormalisedPoint: normalisedPoint
]

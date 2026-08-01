"
I represent an anchor at a body-local point.

My responsibility is to transform that point into world coordinates as the body moves and rotates.
"
Class {
	#name : 'CFPhysicsLocalAnchor',
	#superclass : 'CFPhysicsAnchor',
	#instVars : [ 'localPoint' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsLocalAnchor class >> on: aBodyState at: aPoint [
	^ self new
		body: aBodyState;
		localPoint: aPoint;
		yourself
]

{ #category : 'accessing' }
CFPhysicsLocalAnchor >> localPoint [
	^ localPoint
]

{ #category : 'accessing' }
CFPhysicsLocalAnchor >> localPoint: aPoint [
	localPoint := aPoint
]

{ #category : 'geometry' }
CFPhysicsLocalAnchor >> worldPoint [
	^ self body
		worldPointForBodyLocalPoint:
			(self body shapeState bodyLocalPointForElementLocalPoint: localPoint)
]

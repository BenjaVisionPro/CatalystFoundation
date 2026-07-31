Class {
	#name : 'CFPhysicsLocalAnchor',
	#superclass : 'CFPhysicsAnchor',
	#instVars : [ 'localPoint' ],
	#category : 'BVC-Physics-Core',
	#package : 'BVC-Physics-Core'
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

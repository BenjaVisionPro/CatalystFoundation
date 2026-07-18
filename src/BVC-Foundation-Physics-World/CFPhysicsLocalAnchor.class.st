Class {
	#name : 'CFPhysicsLocalAnchor',
	#superclass : 'CFPhysicsAnchor',
	#instVars : [ 'localPoint' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
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
	^ self body worldPointForLocalPoint: localPoint
]

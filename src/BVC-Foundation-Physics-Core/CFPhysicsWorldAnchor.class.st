Class {
	#name : 'CFPhysicsWorldAnchor',
	#superclass : 'CFPhysicsAnchor',
	#instVars : [ 'world', 'point' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsWorldAnchor class >> in: aWorld at: aPoint [
	^ self new
		world: aWorld;
		point: aPoint;
		yourself
]

{ #category : 'accessing' }
CFPhysicsWorldAnchor >> point [
	^ point
]

{ #category : 'accessing' }
CFPhysicsWorldAnchor >> point: aPoint [
	point := aPoint
]

{ #category : 'accessing' }
CFPhysicsWorldAnchor >> world [
	^ world
]

{ #category : 'accessing' }
CFPhysicsWorldAnchor >> world: aWorld [
	world := aWorld
]

{ #category : 'geometry' }
CFPhysicsWorldAnchor >> worldPoint [
	^ point
]

Class {
	#name : 'CFPhysicsSupportPoint',
	#superclass : 'Object',
	#instVars : [ 'point', 'firstPoint', 'secondPoint' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsSupportPoint class >> point: aPoint firstPoint: aFirstPoint secondPoint: aSecondPoint [
	^ self new
		point: aPoint;
		firstPoint: aFirstPoint;
		secondPoint: aSecondPoint;
		yourself
]

{ #category : 'accessing' }
CFPhysicsSupportPoint >> point [ ^ point ]
{ #category : 'accessing' }
CFPhysicsSupportPoint >> point: aPoint [ point := aPoint ]
{ #category : 'accessing' }
CFPhysicsSupportPoint >> firstPoint [ ^ firstPoint ]
{ #category : 'accessing' }
CFPhysicsSupportPoint >> firstPoint: aPoint [ firstPoint := aPoint ]
{ #category : 'accessing' }
CFPhysicsSupportPoint >> secondPoint [ ^ secondPoint ]
{ #category : 'accessing' }
CFPhysicsSupportPoint >> secondPoint: aPoint [ secondPoint := aPoint ]

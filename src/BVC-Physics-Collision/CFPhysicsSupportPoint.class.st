"
I represent one Minkowski support point and the source point from each shape.

My responsibility is to preserve the geometric witnesses used by GJK, EPA and closest-point calculations.
"
Class {
	#name : 'CFPhysicsSupportPoint',
	#superclass : 'Object',
	#instVars : [ 'point', 'firstPoint', 'secondPoint', 'firstIndex', 'secondIndex' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsSupportPoint class >> point: aPoint firstPoint: aFirstPoint secondPoint: aSecondPoint [
	^ self new
		point: aPoint;
		firstPoint: aFirstPoint;
		secondPoint: aSecondPoint;
		yourself
]

{ #category : 'instance creation' }
CFPhysicsSupportPoint class >> point: aPoint firstPoint: aFirstPoint secondPoint: aSecondPoint firstIndex: aFirstIndex secondIndex: aSecondIndex [
	^ self new
		point: aPoint;
		firstPoint: aFirstPoint;
		secondPoint: aSecondPoint;
		firstIndex: aFirstIndex;
		secondIndex: aSecondIndex;
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
{ #category : 'accessing' }
CFPhysicsSupportPoint >> firstIndex [ ^ firstIndex ]
{ #category : 'accessing' }
CFPhysicsSupportPoint >> firstIndex: anInteger [ firstIndex := anInteger ]
{ #category : 'accessing' }
CFPhysicsSupportPoint >> secondIndex [ ^ secondIndex ]
{ #category : 'accessing' }
CFPhysicsSupportPoint >> secondIndex: anInteger [ secondIndex := anInteger ]

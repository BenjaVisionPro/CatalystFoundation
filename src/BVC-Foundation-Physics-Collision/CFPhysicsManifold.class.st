Class {
	#name : 'CFPhysicsManifold',
	#superclass : 'Object',
	#instVars : [ 'normal', 'penetration', 'points' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsManifold class >> normal: aNormal penetration: aNumber [
	^ self new
		normal: aNormal;
		penetration: aNumber;
		yourself
]

{ #category : 'initialization' }
CFPhysicsManifold >> initialize [
	super initialize.
	points := #()
]

{ #category : 'accessing' }
CFPhysicsManifold >> normal [
	^ normal
]

{ #category : 'accessing' }
CFPhysicsManifold >> normal: aPoint [
	normal := aPoint
]

{ #category : 'accessing' }
CFPhysicsManifold >> penetration [
	^ penetration
]

{ #category : 'accessing' }
CFPhysicsManifold >> penetration: aNumber [
	penetration := aNumber
]

{ #category : 'accessing' }
CFPhysicsManifold >> points [
	^ points
]

{ #category : 'accessing' }
CFPhysicsManifold >> points: aCollection [
	points := aCollection asArray
]

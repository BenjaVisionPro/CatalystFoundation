Class {
	#name : 'CFPhysicsSweep',
	#superclass : 'Object',
	#instVars : [ 'startTransform', 'endTransform' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsSweep class >> from: aStartTransform to: anEndTransform [
	^ self new
		startTransform: aStartTransform;
		endTransform: anEndTransform;
		yourself
]

{ #category : 'accessing' }
CFPhysicsSweep >> endTransform [
	^ endTransform
]

{ #category : 'accessing' }
CFPhysicsSweep >> endTransform: aTransform [
	endTransform := aTransform
]

{ #category : 'accessing' }
CFPhysicsSweep >> startTransform [
	^ startTransform
]

{ #category : 'accessing' }
CFPhysicsSweep >> startTransform: aTransform [
	startTransform := aTransform
]

{ #category : 'interpolating' }
CFPhysicsSweep >> transformAt: alpha [
	^ startTransform interpolatedTo: endTransform at: alpha
]

{ #category : 'geometry' }
CFPhysicsSweep >> sweptAABBFor: aShapeState [
	| startBounds endBounds radius startCentre endCentre minimum maximum |
	startBounds := aShapeState
		aabbAt: startTransform position
		rotation: startTransform rotation.
	endBounds := aShapeState
		aabbAt: endTransform position
		rotation: endTransform rotation.
	startTransform rotation = endTransform rotation ifTrue: [
		^ startBounds mergedWith: endBounds ].

	radius := aShapeState boundingRadius.
	startCentre := aShapeState centreAt: startTransform position.
	endCentre := aShapeState centreAt: endTransform position.
	minimum := ((startCentre x min: endCentre x) - radius)
		@ ((startCentre y min: endCentre y) - radius).
	maximum := ((startCentre x max: endCentre x) + radius)
		@ ((startCentre y max: endCentre y) + radius).
	^ CFPhysicsAABB position: minimum extent: maximum - minimum
]

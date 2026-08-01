"
I represent a body's transform across a simulation interval.

My responsibility is to provide interpolated motion and swept bounds for continuous collision detection.
"
Class {
	#name : 'CFPhysicsSweep',
	#superclass : 'Object',
	#instVars : [ 'startTransform', 'endTransform' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
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

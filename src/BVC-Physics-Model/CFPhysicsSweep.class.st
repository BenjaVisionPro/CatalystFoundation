"
I represent a body's transform across a simulation interval.

My responsibility is to provide interpolated motion and swept bounds for continuous collision detection.

Catalyst stores the body origin at the rotation centre used by its shapes. This is the equivalent of Box2D's swept centre for the current Catalyst mass model, so no separate local-centre offset is required here. Rotations are stored as unwrapped scalar angles and are interpolated directly along the solved angular displacement.
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

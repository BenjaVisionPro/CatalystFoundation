
"I am a captured analytical circle."
Class {
	#name : 'CFPhysicsCapturedCircleGeometry',
	#superclass : 'CFPhysicsCapturedGeometry',
	#instVars : [ 'radius' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsCapturedCircleGeometry class >> radius: aNumber [
	^ self new
		radius: aNumber;
		yourself
]

{ #category : 'testing' }
CFPhysicsCapturedCircleGeometry >> isCircle [
	^ true
]

{ #category : 'accessing' }
CFPhysicsCapturedCircleGeometry >> radius [
	^ radius
]

{ #category : 'accessing' }
CFPhysicsCapturedCircleGeometry >> radius: aNumber [
	radius := aNumber asFloat
]

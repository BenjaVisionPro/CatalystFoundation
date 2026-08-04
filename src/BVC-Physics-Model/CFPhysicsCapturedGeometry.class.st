
"
I am an immutable Physics description captured from an element geometry for one simulation step.

My subclasses contain only Physics values. They do not retain Bloc or Sparta objects.
"
Class {
	#name : 'CFPhysicsCapturedGeometry',
	#superclass : 'Object',
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'testing' }
CFPhysicsCapturedGeometry >> isCircle [
	^ false
]

{ #category : 'testing' }
CFPhysicsCapturedGeometry >> isPolygon [
	^ false
]

{ #category : 'testing' }
CFPhysicsCapturedGeometry >> isRounded [
	^ false
]

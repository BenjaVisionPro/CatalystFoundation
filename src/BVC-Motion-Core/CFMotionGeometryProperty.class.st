"
I represent the exclusive Motion property used to identify geometry-presentation ownership.

I provide the property identity used by geometry tracks and layout retargeting. Geometry presentation itself is performed through CFMotionGeometryTrack and the shared transform channel.
"
Class {
	#name : 'CFMotionGeometryProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Motion-Core',
	#package : 'BVC-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionGeometryProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFMotionGeometryProperty >> currentPresentationOf: anElement [
	^ anElement transformation
]

{ #category : 'accessing' }
CFMotionGeometryProperty >> apply: aTransformation to: anElement [
	anElement transformation: aTransformation
]

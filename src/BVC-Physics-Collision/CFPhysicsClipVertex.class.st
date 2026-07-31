Class {
	#name : 'CFPhysicsClipVertex',
	#superclass : 'Object',
	#instVars : [ 'position', 'incidentVertexIndex' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsClipVertex class >> position: aPoint incidentVertexIndex: anInteger [
	^ self new
		position: aPoint;
		incidentVertexIndex: anInteger;
		yourself
]

{ #category : 'accessing' }
CFPhysicsClipVertex >> position [ ^ position ]

{ #category : 'accessing' }
CFPhysicsClipVertex >> position: aPoint [ position := aPoint ]

{ #category : 'accessing' }
CFPhysicsClipVertex >> incidentVertexIndex [ ^ incidentVertexIndex ]

{ #category : 'accessing' }
CFPhysicsClipVertex >> incidentVertexIndex: anInteger [ incidentVertexIndex := anInteger ]

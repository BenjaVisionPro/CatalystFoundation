"
I represent a polygon vertex while it is being clipped against a reference face.

I retain the Box2D-style contact feature identity and the incident edge index needed when clipping creates an intersection point.
"
Class {
	#name : 'CFPhysicsClipVertex',
	#superclass : 'Object',
	#instVars : [ 'position', 'featureId', 'incidentEdgeIndex' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsClipVertex class >> position: aPoint featureId: aFeatureId incidentEdgeIndex: anInteger [
	^ self new
		position: aPoint;
		featureId: aFeatureId;
		incidentEdgeIndex: anInteger;
		yourself
]

{ #category : 'accessing' }
CFPhysicsClipVertex >> position [ ^ position ]

{ #category : 'accessing' }
CFPhysicsClipVertex >> position: aPoint [ position := aPoint ]

{ #category : 'accessing' }
CFPhysicsClipVertex >> featureId [ ^ featureId ]

{ #category : 'accessing' }
CFPhysicsClipVertex >> featureId: anObject [ featureId := anObject ]

{ #category : 'accessing' }
CFPhysicsClipVertex >> incidentEdgeIndex [ ^ incidentEdgeIndex ]

{ #category : 'accessing' }
CFPhysicsClipVertex >> incidentEdgeIndex: anInteger [ incidentEdgeIndex := anInteger ]

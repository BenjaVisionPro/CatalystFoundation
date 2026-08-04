"
I am the stable user data stored in a broadphase tree proxy.

I identify one collision shape, its owning body and its deterministic index in that body's shape collection.
"
Class {
	#name : 'CFPhysicsBroadphaseEntry',
	#superclass : 'Object',
	#instVars : [ 'body', 'shape', 'shapeIndex' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsBroadphaseEntry class >> body: aBody shape: aShape shapeIndex: anInteger [
	^ self new
		body: aBody;
		shape: aShape;
		shapeIndex: anInteger;
		yourself
]

{ #category : 'accessing' }
CFPhysicsBroadphaseEntry >> body [ ^ body ]

{ #category : 'accessing' }
CFPhysicsBroadphaseEntry >> body: aBody [ body := aBody ]

{ #category : 'accessing' }
CFPhysicsBroadphaseEntry >> shape [ ^ shape ]

{ #category : 'accessing' }
CFPhysicsBroadphaseEntry >> shape: aShape [ shape := aShape ]

{ #category : 'accessing' }
CFPhysicsBroadphaseEntry >> shapeIndex [ ^ shapeIndex ]

{ #category : 'accessing' }
CFPhysicsBroadphaseEntry >> shapeIndex: anInteger [ shapeIndex := anInteger ]

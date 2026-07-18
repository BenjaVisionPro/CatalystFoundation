Class {
	#name : 'CFPhysicsAnchor',
	#superclass : 'Object',
	#instVars : [ 'body' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
}

{ #category : 'instance creation' }
CFPhysicsAnchor class >> on: aBodyState [
	^ self new
		body: aBodyState;
		yourself
]

{ #category : 'accessing' }
CFPhysicsAnchor >> body [ ^ body ]

{ #category : 'accessing' }
CFPhysicsAnchor >> body: aBodyState [ body := aBodyState ]

{ #category : 'geometry' }
CFPhysicsAnchor >> worldPoint [
	self subclassResponsibility
]

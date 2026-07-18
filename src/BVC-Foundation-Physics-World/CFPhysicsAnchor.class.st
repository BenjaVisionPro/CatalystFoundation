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

{ #category : 'private - relationships' }
CFPhysicsAnchor >> relationshipWorldWith: anotherAnchor [
	| firstWorld secondWorld |
	firstWorld := self body world.
	secondWorld := anotherAnchor body world.
	(firstWorld notNil and: [ firstWorld == secondWorld ])
		ifFalse: [ self error: 'Both anchors must belong to bodies in the same physics world' ].
	^ firstWorld
]

{ #category : 'relationships' }
CFPhysicsAnchor >> springTo: anotherAnchor [
	| aWorld spring |
	aWorld := self relationshipWorldWith: anotherAnchor.
	spring := CFPhysicsSpringConstraint betweenAnchor: self andAnchor: anotherAnchor.
	^ aWorld addSpringConstraint: spring
]

{ #category : 'relationships' }
CFPhysicsAnchor >> attract: anotherAnchor [
	| aWorld attraction |
	aWorld := self relationshipWorldWith: anotherAnchor.
	attraction := CFPhysicsAttractionConstraint betweenAnchor: self andAnchor: anotherAnchor.
	^ aWorld addAttractionConstraint: attraction
]

{ #category : 'relationships' }
CFPhysicsAnchor >> repel: anotherAnchor [
	| aWorld repulsion |
	aWorld := self relationshipWorldWith: anotherAnchor.
	repulsion := CFPhysicsRepulsionConstraint betweenAnchor: self andAnchor: anotherAnchor.
	^ aWorld addRepulsionConstraint: repulsion
]

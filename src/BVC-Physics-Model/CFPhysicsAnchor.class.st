"
I represent one endpoint of a physical relationship.

My responsibility is to resolve a world-space point while preserving whether that point belongs to a body or to the world.
"
Class {
	#name : 'CFPhysicsAnchor',
	#superclass : 'Object',
	#instVars : [ 'body' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
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

{ #category : 'accessing' }
CFPhysicsAnchor >> world [
	^ body world
]

{ #category : 'geometry' }
CFPhysicsAnchor >> worldPoint [
	self subclassResponsibility
]

{ #category : 'private - relationships' }
CFPhysicsAnchor >> relationshipWorldWith: anotherAnchor [
	| firstWorld secondWorld |
	firstWorld := self world.
	secondWorld := anotherAnchor world.
	(firstWorld notNil and: [ firstWorld == secondWorld ])
		ifFalse: [ self error: 'Both anchors must belong to the same physics world' ].
	(self body isNil and: [ anotherAnchor body isNil ])
		ifTrue: [ self error: 'A relationship requires at least one body anchor' ].
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
CFPhysicsAnchor >> distanceJointTo: anotherAnchor [
	| aWorld joint |
	aWorld := self relationshipWorldWith: anotherAnchor.
	joint := CFPhysicsDistanceJoint betweenAnchor: self andAnchor: anotherAnchor.
	^ aWorld addDistanceJoint: joint
]

{ #category : 'relationships' }
CFPhysicsAnchor >> revoluteJointTo: anotherAnchor [
	| aWorld joint |
	aWorld := self relationshipWorldWith: anotherAnchor.
	joint := CFPhysicsRevoluteJoint betweenAnchor: self andAnchor: anotherAnchor.
	^ aWorld addRevoluteJoint: joint
]

{ #category : 'relationships' }
CFPhysicsAnchor >> weldJointTo: anotherAnchor [
	| aWorld joint |
	aWorld := self relationshipWorldWith: anotherAnchor.
	joint := CFPhysicsWeldJoint betweenAnchor: self andAnchor: anotherAnchor.
	^ aWorld addWeldJoint: joint
]

{ #category : 'relationships' }
CFPhysicsAnchor >> prismaticJointTo: anotherAnchor along: anAxis [
	| aWorld joint |
	aWorld := self relationshipWorldWith: anotherAnchor.
	joint := CFPhysicsPrismaticJoint betweenAnchor: self andAnchor: anotherAnchor along: anAxis.
	^ aWorld addPrismaticJoint: joint
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

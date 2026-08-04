"
I represent the Box2D 3.1.1 filter joint between two bodies.

My responsibility is to initially suppress collisions for my body pair while
remaining a joint edge in the persistent island graph. I deliberately produce
no solver constraint or impulse.
"
Class {
	#name : 'CFPhysicsFilterJoint',
	#superclass : 'CFPhysicsJoint',
	#instVars : [ 'bodyA', 'bodyB' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsFilterJoint class >> between: aBody and: anotherBody [
	^ self new
		bodyA: aBody;
		bodyB: anotherBody;
		yourself
]

{ #category : 'accessing' }
CFPhysicsFilterJoint >> bodyA [ ^ bodyA ]

{ #category : 'accessing' }
CFPhysicsFilterJoint >> bodyA: aBody [ bodyA := aBody ]

{ #category : 'accessing' }
CFPhysicsFilterJoint >> bodyB [ ^ bodyB ]

{ #category : 'accessing' }
CFPhysicsFilterJoint >> bodyB: aBody [ bodyB := aBody ]

{ #category : 'testing' }
CFPhysicsFilterJoint >> includesBody: aBody [
	^ bodyA == aBody or: [ bodyB == aBody ]
]

{ #category : 'testing' }
CFPhysicsFilterJoint >> includesAnchor: anAnchor [ ^ false ]

{ #category : 'capturing' }
CFPhysicsFilterJoint >> capturedForStep [
	| captured |
	captured := self shallowCopy.
	captured sourceJoint: self.
	^ captured
]

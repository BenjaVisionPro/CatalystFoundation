"
I represent the shared lifecycle of a joint between two physics bodies.

My responsibility is to retain activation, ordering, collision and solver-commit state common to every joint. Concrete joints own their bodies, geometry, configuration and accumulated impulses.
"
Class {
	#name : 'CFPhysicsJoint',
	#superclass : 'Object',
	#instVars : [ 'active', 'sequence', 'collideConnected', 'sourceJoint' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsJoint >> initialize [
	super initialize.
	active := true.
	sequence := 0.
	collideConnected := false
]

{ #category : 'configuration' }
CFPhysicsJoint >> collideConnected [ ^ collideConnected ]

{ #category : 'configuration' }
CFPhysicsJoint >> collideConnected: aBoolean [
	collideConnected = aBoolean ifTrue: [ ^ self ].
	collideConnected := aBoolean.
	self wakeBodies
]

{ #category : 'ordering' }
CFPhysicsJoint >> sequence [ ^ sequence ]

{ #category : 'ordering' }
CFPhysicsJoint >> sequence: anInteger [ sequence := anInteger ]

{ #category : 'ordering' }
CFPhysicsJoint >> orderingKey [ ^ sequence ]

{ #category : 'testing' }
CFPhysicsJoint >> isActive [ ^ active ]

{ #category : 'waking' }
CFPhysicsJoint >> wakeBodies [
	self bodyA ifNotNil: [ :body | body wake ].
	self bodyB ifNotNil: [ :body | body wake ]
]

{ #category : 'controlling' }
CFPhysicsJoint >> release [ active := false ]

{ #category : 'private - capturing' }
CFPhysicsJoint >> sourceJoint: aJoint [ sourceJoint := aJoint ]

{ #category : 'committing' }
CFPhysicsJoint >> solverCommitTarget [ ^ sourceJoint ifNil: [ self ] ]

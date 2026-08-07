"
I represent the shared lifecycle of a Physics joint.

My responsibility is to retain activation, ordering, collision and solver-commit state common to every joint. Concrete joints own their bodies, geometry, configuration and accumulated impulses.
"
Class {
	#name : 'CFPhysicsJoint',
	#superclass : 'Object',
	#instVars : [ 'active', 'sequence', 'collideConnected', 'sourceJoint', 'world' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsJoint >> initialize [
	super initialize.
	active := true.
	sequence := 0.
	collideConnected := false.
	world := nil
]

{ #category : 'configuration' }
CFPhysicsJoint >> collideConnected [ ^ collideConnected ]

{ #category : 'configuration' }
CFPhysicsJoint >> collideConnected: aBoolean [
	| body |
	collideConnected = aBoolean ifTrue: [ ^ self ].
	collideConnected := aBoolean.
	aBoolean ifTrue: [
		body := self bodyA ifNil: [ self bodyB ].
		body ifNotNil: [ :aBody |
			aBody world ifNotNil: [ :world | world touchBroadphaseProxyFor: aBody ] ] ].
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

{ #category : 'accessing' }
CFPhysicsJoint >> world [
	^ world
]

{ #category : 'lifecycle' }
CFPhysicsJoint >> addedToWorld: aWorld [
	world ifNotNil: [ self error: 'Joint already belongs to a Physics world' ].
	active ifFalse: [ self error: 'A removed joint cannot be added to a Physics world' ].
	world := aWorld
]

{ #category : 'lifecycle' }
CFPhysicsJoint >> remove [
	world ifNotNil: [ world removeJoint: self ]
]

{ #category : 'lifecycle' }
CFPhysicsJoint >> removedFromWorld [
	world := nil.
	active := false
]

{ #category : 'controlling' }
CFPhysicsJoint >> release [
	self removedFromWorld
]

{ #category : 'private - capturing' }
CFPhysicsJoint >> sourceJoint: aJoint [
	sourceJoint := aJoint.
	world := nil
]

{ #category : 'committing' }
CFPhysicsJoint >> solverCommitTarget [ ^ sourceJoint ifNil: [ self ] ]

{ #category : 'validation' }
CFPhysicsJoint >> validateForWorld: aWorld [
	(self bodyA isNil and: [ self bodyB isNil ]) ifTrue: [
		self error: 'A joint requires at least one body' ].
	self bodyA ifNotNil: [ :body |
		body world == aWorld ifFalse: [
			self error: 'Joint bodies must belong to the Physics world' ] ].
	self bodyB ifNotNil: [ :body |
		body world == aWorld ifFalse: [
			self error: 'Joint bodies must belong to the Physics world' ] ]
]

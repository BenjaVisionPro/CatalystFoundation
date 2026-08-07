"
I represent a persistent physical influence owned by a Physics world.

My responsibility is to contribute physical effects before the world captures state for a simulation step.
"
Class {
	#name : 'CFPhysicsForce',
	#superclass : 'Object',
	#instVars : [ 'world' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsForce >> initialize [
	super initialize.
	world := nil
]

{ #category : 'accessing' }
CFPhysicsForce >> world [
	^ world
]

{ #category : 'lifecycle' }
CFPhysicsForce >> addedToWorld: aWorld [
	world ifNotNil: [ self error: 'Force already belongs to a Physics world' ].
	world := aWorld
]

{ #category : 'lifecycle' }
CFPhysicsForce >> remove [
	world ifNotNil: [ world removeForce: self ]
]


{ #category : 'lifecycle' }
CFPhysicsForce >> removeBody: aBody [
	(self includesBody: aBody) ifTrue: [ self remove ]
]

{ #category : 'lifecycle' }
CFPhysicsForce >> removedFromWorld [
	world := nil
]


{ #category : 'testing' }
CFPhysicsForce >> isActive [
	^ world notNil
]

{ #category : 'testing' }
CFPhysicsForce >> includesBody: aBody [
	^ false
]

{ #category : 'stepping' }
CFPhysicsForce >> applyForStep: seconds [
	self subclassResponsibility
]

{ #category : 'validation' }
CFPhysicsForce >> validateForWorld: aWorld [
]

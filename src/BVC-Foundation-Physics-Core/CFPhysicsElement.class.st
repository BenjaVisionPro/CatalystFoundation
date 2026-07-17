Class {
	#name : 'CFPhysicsElement',
	#superclass : 'Object',
	#instVars : [ 'element', 'world' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsElement class >> on: anElement [
	^ self new
		element: anElement;
		yourself
]

{ #category : 'worlds' }
CFPhysicsElement >> beWorld [
	world ifNil: [ world := CFPhysicsWorld on: element ].
	^ world
]

{ #category : 'accessing' }
CFPhysicsElement >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsElement >> element: anElement [
	element := anElement
]

{ #category : 'worlds' }
CFPhysicsElement >> existingWorld [
	^ world
]

{ #category : 'worlds' }
CFPhysicsElement >> isWorld [
	^ world notNil
]

{ #category : 'worlds' }
CFPhysicsElement >> owningWorld [
	| ancestor physics |
	ancestor := element parent.
	[ ancestor notNil ] whileTrue: [
		physics := ancestor existingPhysics.
		physics ifNotNil: [
			physics existingWorld ifNotNil: [ :anExistingWorld |
				^ anExistingWorld ] ].
		ancestor := ancestor parent ].
	^ nil
]

{ #category : 'worlds' }
CFPhysicsElement >> synchroniseWorldMembership [
	| owningWorld |
	owningWorld := self owningWorld.
	world ifNotNil: [ world synchroniseMembership ].
	owningWorld ifNotNil: [ owningWorld synchroniseMembership ].
	^ owningWorld
]

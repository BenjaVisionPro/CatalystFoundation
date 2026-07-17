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


{ #category : 'bodies' }
CFPhysicsElement >> bodyState [
	| owningWorld |
	world ifNotNil: [ ^ nil ].
	owningWorld := self owningWorld.
	owningWorld ifNil: [ ^ nil ].
	^ owningWorld bodyStateFor: element
]

{ #category : 'bodies' }
CFPhysicsElement >> position [
	^ self requireBodyState position
]

{ #category : 'bodies' }
CFPhysicsElement >> position: aPoint [
	self requireBodyState position: aPoint
]

{ #category : 'bodies' }
CFPhysicsElement >> presentation [
	^ self requireBodyState presentation
]

{ #category : 'private - bodies' }
CFPhysicsElement >> requireBodyState [
	| owningWorld bodyState |
	world ifNotNil: [ self error: 'A world owner is not a body in its own world' ].
	owningWorld := self owningWorld.
	owningWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	bodyState := owningWorld bodyStateFor: element.
	bodyState ifNil: [
		owningWorld synchroniseMembership.
		bodyState := owningWorld bodyStateFor: element ].
	bodyState ifNil: [ self error: 'The element is not tracked by its physics world' ].
	^ bodyState
]

{ #category : 'bodies' }
CFPhysicsElement >> rotation [
	^ self requireBodyState rotation
]

{ #category : 'bodies' }
CFPhysicsElement >> rotation: aNumber [
	self requireBodyState rotation: aNumber
]

{ #category : 'bodies' }
CFPhysicsElement >> translation: aPoint rotation: aNumber [
	self requireBodyState translation: aPoint rotation: aNumber
]

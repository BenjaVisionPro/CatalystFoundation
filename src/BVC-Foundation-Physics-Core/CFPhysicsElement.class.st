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

{ #category : 'body type' }
CFPhysicsElement >> beDynamic [
	self requireBodyState beDynamic
]

{ #category : 'body type' }
CFPhysicsElement >> beStatic [
	self requireBodyState beStatic
]

{ #category : 'worlds' }
CFPhysicsElement >> beWorld [
	world ifNil: [ world := CFPhysicsWorld on: element ].
	^ world
]

{ #category : 'bodies' }
CFPhysicsElement >> bodyState [
	| owningWorld |
	owningWorld := self owningWorld.
	owningWorld ifNil: [ ^ nil ].
	^ owningWorld bodyStateFor: element
]

{ #category : 'accessing' }
CFPhysicsElement >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsElement >> element: anElement [
	element := anElement
]


{ #category : 'material' }
CFPhysicsElement >> density [
	^ self requireBodyState density
]

{ #category : 'material' }
CFPhysicsElement >> density: aNumber [
	self requireBodyState density: aNumber
]

{ #category : 'material' }
CFPhysicsElement >> friction [
	^ self requireBodyState friction
]

{ #category : 'material' }
CFPhysicsElement >> friction: aNumber [
	self requireBodyState friction: aNumber
]

{ #category : 'material' }
CFPhysicsElement >> restitution [
	^ self requireBodyState restitution
]

{ #category : 'material' }
CFPhysicsElement >> restitution: aNumber [
	self requireBodyState restitution: aNumber
]

{ #category : 'worlds' }
CFPhysicsElement >> existingWorld [
	^ world
]

{ #category : 'body type' }
CFPhysicsElement >> isDynamic [
	^ self requireBodyState isDynamic
]

{ #category : 'body type' }
CFPhysicsElement >> isStatic [
	^ self requireBodyState isStatic
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

{ #category : 'worlds' }
CFPhysicsElement >> synchroniseWorldMembership [
	| owningWorld |
	owningWorld := self owningWorld.
	world ifNotNil: [ world synchroniseMembership ].
	owningWorld ifNotNil: [ owningWorld synchroniseMembership ].
	^ owningWorld
]

{ #category : 'bodies' }
CFPhysicsElement >> translation: aPoint rotation: aNumber [
	self requireBodyState translation: aPoint rotation: aNumber
]

{ #category : 'bodies' }
CFPhysicsElement >> velocity [
	^ self requireBodyState velocity
]

{ #category : 'bodies' }
CFPhysicsElement >> velocity: aPoint [
	self requireBodyState velocity: aPoint
]


{ #category : 'sleeping' }
CFPhysicsElement >> isAwake [
	^ self requireBodyState isAwake
]

{ #category : 'sleeping' }
CFPhysicsElement >> isSleeping [
	^ self requireBodyState isSleeping
]

{ #category : 'sleeping' }
CFPhysicsElement >> sleep [
	self requireBodyState sleep
]

{ #category : 'sleeping' }
CFPhysicsElement >> wake [
	self requireBodyState wake
]

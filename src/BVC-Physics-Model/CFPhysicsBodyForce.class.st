"
I represent a force applied to a configurable collection of Physics bodies.

My responsibility is to retain the affected bodies and keep that membership valid as bodies leave the world.
"
Class {
	#name : 'CFPhysicsBodyForce',
	#superclass : 'CFPhysicsForce',
	#instVars : [ 'bodies' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsBodyForce >> initialize [
	super initialize.
	bodies := #()
]

{ #category : 'accessing' }
CFPhysicsBodyForce >> bodies [
	^ bodies
]

{ #category : 'accessing' }
CFPhysicsBodyForce >> bodies: aCollection [
	| newBodies oldBodies |
	newBodies := aCollection asArray.
	world ifNotNil: [
		newBodies do: [ :body |
			body world == world ifFalse: [
				self error: 'Force bodies must belong to the Physics world' ] ] ].
	((bodies size = newBodies size) and: [
		bodies allSatisfy: [ :body | newBodies identityIncludes: body ] ]) ifTrue: [ ^ self ].
	oldBodies := bodies.
	bodies := newBodies.
	world ifNotNil: [ world wakeBodies: oldBodies , newBodies ]
]

{ #category : 'waking' }
CFPhysicsBodyForce >> affectedBodies [
	^ bodies
]

{ #category : 'testing' }
CFPhysicsBodyForce >> includesBody: aBody [
	^ bodies identityIncludes: aBody
]

{ #category : 'lifecycle' }
CFPhysicsBodyForce >> removeBody: aBody [
	bodies := bodies reject: [ :each | each == aBody ].
	bodies ifEmpty: [ self remove ]
]

{ #category : 'validation' }
CFPhysicsBodyForce >> validateForWorld: aWorld [
	bodies do: [ :body |
		body world == aWorld ifFalse: [
			self error: 'Force bodies must belong to the Physics world' ] ]
]

Class {
	#name : 'CFPhysicsWorldPresentation',
	#superclass : 'Object',
	#instVars : [ 'world', 'coordinator', 'presentations' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
}

{ #category : 'instance creation' }
CFPhysicsWorldPresentation class >> on: aWorld in: aCoordinator [
	^ self new
		world: aWorld;
		coordinator: aCoordinator;
		yourself
]

{ #category : 'initialization' }
CFPhysicsWorldPresentation >> initialize [
	super initialize.
	presentations := IdentityDictionary new
]

{ #category : 'presenting' }
CFPhysicsWorldPresentation >> presentAtAlpha: aNumber [
	world synchroniseMembership.
	self synchronisePresentations.
	world bodyStatesInOrder do: [ :each | each presentAtAlpha: aNumber ]
]

{ #category : 'private - presenting' }
CFPhysicsWorldPresentation >> synchronisePresentations [
	| bodyStates currentBodies |
	bodyStates := world bodyStatesInOrder.
	currentBodies := IdentitySet new.
	currentBodies addAll: bodyStates.
	(presentations keys reject: [ :each | currentBodies includes: each ]) do: [ :each |
		(presentations removeKey: each) release ].
	bodyStates do: [ :each |
		presentations at: each ifAbsentPut: [
			| transformPresentation |
			transformPresentation := CFMotionTransformPresentation
				on: each element
				using: (coordinator transformChannelFor: each element).
			each usePresentation: transformPresentation.
			transformPresentation ] ]
]

{ #category : 'controlling' }
CFPhysicsWorldPresentation >> release [
	presentations keysAndValuesDo: [ :body :each |
		body presentation release ].
	presentations removeAll
]

{ #category : 'private - initialization' }
CFPhysicsWorldPresentation >> world: aWorld [
	world := aWorld
]

{ #category : 'private - initialization' }
CFPhysicsWorldPresentation >> coordinator: aCoordinator [
	coordinator := aCoordinator
]

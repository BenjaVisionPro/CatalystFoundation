Class {
	#name : 'CFPhysicsWorldPresentation',
	#superclass : 'Object',
	#instVars : [ 'world', 'coordinator', 'presentations', 'fixedCoordinator' ],
	#category : 'BVC-Foundation-Physics-Motion',
	#package : 'BVC-Foundation-Physics-Motion'
}

{ #category : 'instance creation' }
CFPhysicsWorldPresentation class >> on: aWorld [
	^ self new
		world: aWorld;
		yourself
]

{ #category : 'instance creation' }
CFPhysicsWorldPresentation class >> on: aWorld in: aCoordinator [
	^ self new
		world: aWorld;
		coordinator: aCoordinator;
		useFixedCoordinator;
		yourself
]

{ #category : 'initialization' }
CFPhysicsWorldPresentation >> initialize [
	super initialize.
	presentations := IdentityDictionary new.
	fixedCoordinator := false
]


{ #category : 'consuming frames' }
CFPhysicsWorldPresentation >> frameReadyAtAlpha: aNumber [
	(self tryPresentAtAlpha: aNumber) ifFalse: [ ^ self ].
	world owner ifNotNil: [ :anOwner |
		anOwner fireEvent: (CFPhysicsFramePresentedEvent new alpha: aNumber; yourself) ].
	^ self
]

{ #category : 'presenting' }
CFPhysicsWorldPresentation >> present [
	self prepare ifFalse: [ ^ self ].
	world synchroniseMembership.
	self synchronisePresentations.
	world bodyStatesInOrder do: [ :each |
		(self presentationFor: each)
			translation: (self translationFor: each at: each position)
			rotation: each rotation radiansToDegrees ]
]

{ #category : 'presenting' }
CFPhysicsWorldPresentation >> presentAtAlpha: aNumber [
	self tryPresentAtAlpha: aNumber.
	^ self
]

{ #category : 'private - presenting' }
CFPhysicsWorldPresentation >> tryPresentAtAlpha: aNumber [
	| alpha |
	self prepare ifFalse: [ ^ false ].
	world synchroniseMembership.
	self synchronisePresentations.
	alpha := (aNumber max: 0.0) min: 1.0.
	world bodyStatesInOrder do: [ :each |
		| presentedPosition presentedRotation |
		presentedPosition := each previousPosition + ((each position - each previousPosition) * alpha).
		presentedRotation := each previousRotation + ((each rotation - each previousRotation) * alpha).
		(self presentationFor: each)
			translation: (self translationFor: each at: presentedPosition)
			rotation: presentedRotation radiansToDegrees ].
	^ true
]

{ #category : 'private - presenting' }
CFPhysicsWorldPresentation >> translationFor: aBodyState at: aPhysicsPosition [
	"Physics positions are absolute in the world owner's local coordinates, while
	Motion translation is applied on top of the element's existing Bloc position.
	Translate only by the difference so the displayed top-left remains equal to
	the Physics position."
	^ aPhysicsPosition - aBodyState element position
]

{ #category : 'private - presenting' }
CFPhysicsWorldPresentation >> prepare [
	| currentCoordinator |
	fixedCoordinator ifTrue: [ ^ coordinator notNil ].
	currentCoordinator := self resolvedCoordinator.
	currentCoordinator ifNil: [
		self releasePresentations.
		coordinator := nil.
		^ false ].
	coordinator == currentCoordinator ifFalse: [
		self releasePresentations.
		coordinator := currentCoordinator ].
	^ true
]

{ #category : 'private - presenting' }
CFPhysicsWorldPresentation >> resolvedCoordinator [
	| owner |
	owner := world owner.
	(owner notNil and: [ owner isAttachedToSceneGraph ]) ifFalse: [ ^ nil ].
	^ owner space cfMotionCoordinator
]

{ #category : 'private - presenting' }
CFPhysicsWorldPresentation >> synchronisePresentations [
	| bodyStates currentBodies transformPresentation |
	bodyStates := world bodyStatesInOrder.
	currentBodies := IdentitySet new.
	currentBodies addAll: bodyStates.
	(presentations keys reject: [ :each | currentBodies includes: each ]) do: [ :each |
		(presentations removeKey: each) release ].
	bodyStates do: [ :each |
		transformPresentation := presentations at: each ifAbsent: [ nil ].
		(transformPresentation isNil or: [ transformPresentation isActive not ]) ifTrue: [
			transformPresentation ifNotNil: [ transformPresentation release ].
			transformPresentation := CFMotionTransformPresentation
				on: each element
				using: (coordinator transformChannelFor: each element).
			presentations at: each put: transformPresentation ] ]
]


{ #category : 'accessing' }
CFPhysicsWorldPresentation >> presentationFor: aBodyState [
	^ presentations at: aBodyState
]

{ #category : 'testing' }
CFPhysicsWorldPresentation >> isPresenting: aBodyState [
	| aPresentation |
	aPresentation := presentations at: aBodyState ifAbsent: [ ^ false ].
	^ aPresentation isActive
]

{ #category : 'controlling' }
CFPhysicsWorldPresentation >> release [
	self releasePresentations.
	fixedCoordinator ifFalse: [ coordinator := nil ]
]

{ #category : 'private - controlling' }
CFPhysicsWorldPresentation >> releasePresentations [
	presentations valuesDo: [ :each | each release ].
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

{ #category : 'private - initialization' }
CFPhysicsWorldPresentation >> useFixedCoordinator [
	fixedCoordinator := true
]

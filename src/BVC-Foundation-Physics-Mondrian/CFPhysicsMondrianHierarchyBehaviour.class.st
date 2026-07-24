"
I keep the first layer of a directed Mondrian graph anchored near the canvas
centre without prescribing the placement of descendants.

A single root is anchored exactly at the centre. Multiple roots are assigned
deterministic positions on a compact central ring. Dynamic roots drift back to
their assigned anchor after being moved.
"
Class {
	#name : 'CFPhysicsMondrianHierarchyBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [ 'nodes', 'connections', 'centre', 'rootRadius', 'restoringStrength', 'velocityDamping' ],
	#category : 'BVC-Foundation-Physics-Mondrian',
	#package : 'BVC-Foundation-Physics-Mondrian'
}

{ #category : 'initialization' }
CFPhysicsMondrianHierarchyBehaviour >> initialize [
	super initialize.
	rootRadius := 42.0.
	restoringStrength := 12.0.
	velocityDamping := 4.0
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> nodes: aCollectionOrProvider [
	nodes := aCollectionOrProvider.
	^ self
]

{ #category : 'accessing' }
CFPhysicsMondrianHierarchyBehaviour >> nodes [
	^ self resolvedParticipantsFrom: nodes default: [ #() ]
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> connections: aCollectionOrProvider [
	connections := aCollectionOrProvider.
	^ self
]

{ #category : 'accessing' }
CFPhysicsMondrianHierarchyBehaviour >> connections [
	^ self resolvedParticipantsFrom: connections default: [ #() ]
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> centre: aPointOrProvider [
	centre := aPointOrProvider.
	^ self
]

{ #category : 'accessing' }
CFPhysicsMondrianHierarchyBehaviour >> centre [
	^ centre value
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> rootRadius [
	^ rootRadius
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> rootRadius: aNumber [
	rootRadius := aNumber asFloat max: 0.0
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> restoringStrength [
	^ restoringStrength
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> restoringStrength: aNumber [
	restoringStrength := aNumber asFloat max: 0.0
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> velocityDamping [
	^ velocityDamping
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> velocityDamping: aNumber [
	velocityDamping := aNumber asFloat max: 0.0
]

{ #category : 'updating' }
CFPhysicsMondrianHierarchyBehaviour >> updateForStep: aPhysicsStep [
	| currentNodes roots targets |
	currentNodes := self nodes.
	currentNodes isEmpty ifTrue: [ ^ self ].
	roots := self rootsAmong: currentNodes connections: self connections.
	targets := self rootTargetsFor: roots.
	self guideRoots: roots towards: targets over: aPhysicsStep timeStep
]

{ #category : 'private - roots' }
CFPhysicsMondrianHierarchyBehaviour >> rootsAmong: currentNodes connections: currentConnections [
	| nodeSet incoming roots |
	nodeSet := currentNodes asIdentitySet.
	incoming := IdentitySet new.
	currentConnections do: [ :connection |
		((nodeSet includes: connection key) and: [ nodeSet includes: connection value ])
			ifTrue: [ incoming add: connection value ] ].
	roots := currentNodes reject: [ :node | incoming includes: node ].
	^ roots isEmpty
		ifTrue: [ { currentNodes first } ]
		ifFalse: [ roots ]
]

{ #category : 'private - roots' }
CFPhysicsMondrianHierarchyBehaviour >> rootTargetsFor: roots [
	| targets count radius |
	targets := IdentityDictionary new.
	count := roots size.
	radius := count = 1 ifTrue: [ 0.0 ] ifFalse: [ rootRadius ].
	roots withIndexDo: [ :root :index |
		| angle direction |
		angle := (Float twoPi * (index - 1) / count) - (Float pi / 2.0).
		direction := angle cos @ angle sin.
		targets at: root put: self centre + (direction * radius) ].
	^ targets
]

{ #category : 'private - forces' }
CFPhysicsMondrianHierarchyBehaviour >> guideRoots: roots towards: targets over: seconds [
	| dampingFactor |
	dampingFactor := 1.0 / (1.0 + (seconds * velocityDamping)).
	roots do: [ :element |
		| body targetPosition displacement restoredVelocity |
		body := element physics requireBodyState.
		body isDynamic ifTrue: [
			targetPosition := (targets at: element) - (body extent / 2.0).
			displacement := targetPosition - body position.
			restoredVelocity := body velocity
				+ (displacement * (restoringStrength * seconds)).
			body velocity: restoredVelocity * dampingFactor ] ]
]

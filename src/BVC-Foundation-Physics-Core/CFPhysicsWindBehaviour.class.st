"
I continuously apply a directional force to a changing Bloc-native selection.

By default I affect my anchor, when it is a member of my world, and all of its descendants that belong to the same world. An elements block may provide a domain-specific changing selection instead. I preserve the supplied or Bloc traversal order and resolve bodies at each simulation step.
"
Class {
	#name : 'CFPhysicsWindBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [ 'force', 'elementsBlock' ],
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'initialization' }
CFPhysicsWindBehaviour >> initialize [
	super initialize.
	force := 50.0 @ 0.0
]

{ #category : 'configuration' }
CFPhysicsWindBehaviour >> force [
	^ force
]

{ #category : 'configuration' }
CFPhysicsWindBehaviour >> force: aPoint [
	force := aPoint
]

{ #category : 'configuration' }
CFPhysicsWindBehaviour >> elementsBlock [
	^ elementsBlock
]

{ #category : 'configuration' }
CFPhysicsWindBehaviour >> elementsBlock: aBlock [
	elementsBlock := aBlock
]

{ #category : 'accessing' }
CFPhysicsWindBehaviour >> elements [
	^ elementsBlock
		ifNil: [ self defaultElements ]
		ifNotNil: [ elementsBlock value asArray ]
]

{ #category : 'private - selection' }
CFPhysicsWindBehaviour >> defaultElements [
	| selected |
	selected := OrderedCollection new.
	self collectApplicableElementsFrom: element into: selected.
	^ selected asArray
]

{ #category : 'private - selection' }
CFPhysicsWindBehaviour >> collectApplicableElementsFrom: anElement into: selected [
	(world includes: anElement) ifTrue: [ selected add: anElement ].
	anElement children do: [ :each |
		self collectApplicableElementsFrom: each into: selected ]
]

{ #category : 'private - selection' }
CFPhysicsWindBehaviour >> bodyFor: anElement [
	(anElement physics behaviourWorld == world) ifFalse: [
		self error: 'Every Wind element must belong to the Behaviour physics world' ].
	(world includes: anElement) ifFalse: [
		self error: 'Every Wind element must be tracked by the Behaviour physics world' ].
	^ world bodyStateFor: anElement
]

{ #category : 'updating' }
CFPhysicsWindBehaviour >> updateForStep: aPhysicsStep [
	self elements do: [ :each |
		(self bodyFor: each) applyForce: force ]
]

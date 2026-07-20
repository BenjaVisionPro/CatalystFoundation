Class {
	#name : 'CFPhysicsPostSolveCollector',
	#superclass : 'Object',
	#instVars : [ 'hitEventThreshold' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsPostSolveCollector >> initialize [
	super initialize.
	hitEventThreshold := 1.0
]

{ #category : 'collecting' }
CFPhysicsPostSolveCollector >> collectFrom: constraints [
	| contactConstraints results events |
	contactConstraints := constraints select: [ :constraint |
		constraint isKindOf: CFPhysicsPreparedConstraint ].
	results := contactConstraints collect: [ :constraint |
		CFPhysicsContactSolveResult fromConstraint: constraint ].
	events := OrderedCollection new.
	results do: [ :result |
		result points do: [ :point |
			((point approachSpeed > hitEventThreshold) and: [ point normalImpulse > 0.0 ]) ifTrue: [
				events add: (CFPhysicsContactHitEvent
					contact: result contact
					normal: result normal
					pointResult: point) ] ] ].
	^ CFPhysicsPostSolveBatch contactResults: results hitEvents: events
]

{ #category : 'accessing' }
CFPhysicsPostSolveCollector >> hitEventThreshold [ ^ hitEventThreshold ]
{ #category : 'accessing' }
CFPhysicsPostSolveCollector >> hitEventThreshold: aNumber [
	hitEventThreshold := aNumber asFloat max: 0.0
]

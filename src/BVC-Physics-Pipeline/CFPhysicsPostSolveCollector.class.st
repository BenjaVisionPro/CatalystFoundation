"
I collect contact impulses and hit events from solved constraints. I convert solver state into stable post-solve observations.
"

Class {
	#name : 'CFPhysicsPostSolveCollector',
	#superclass : 'Object',
	#instVars : [ 'hitEventThreshold' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
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
		| hitPoint |
		hitPoint := nil.
		result points do: [ :point |
			((point approachSpeed > hitEventThreshold)
				and: [ point totalNormalImpulse > 0.0 ]) ifTrue: [
				(hitPoint isNil or: [ point approachSpeed > hitPoint approachSpeed ])
					ifTrue: [ hitPoint := point ] ] ].
		hitPoint ifNotNil: [
			events add: (CFPhysicsContactHitEvent
				contact: result contact
				normal: result normal
				pointResult: hitPoint) ] ].
	^ CFPhysicsPostSolveBatch contactResults: results hitEvents: events
]

{ #category : 'accessing' }
CFPhysicsPostSolveCollector >> hitEventThreshold [ ^ hitEventThreshold ]
{ #category : 'accessing' }
CFPhysicsPostSolveCollector >> hitEventThreshold: aNumber [
	hitEventThreshold := aNumber asFloat max: 0.0
]

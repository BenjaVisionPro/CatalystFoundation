"
I represent a connected group of bodies and constraints that can be solved together. I provide the body classifications and ordering needed by solving and sleeping.
"

Class {
	#name : 'CFPhysicsIsland',
	#superclass : 'Object',
	#instVars : [ 'bodies', 'constraints', 'identifier', 'parentIsland', 'constraintRemoveCount' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsIsland >> initialize [
	super initialize.
	bodies := OrderedCollection new.
	constraints := OrderedCollection new.
	parentIsland := nil.
	constraintRemoveCount := 0
]

{ #category : 'building' }
CFPhysicsIsland >> addBody: aBody [
	(bodies includes: aBody) ifFalse: [ bodies add: aBody ]
]

{ #category : 'building' }
CFPhysicsIsland >> addConstraint: aConstraint [
	(constraints includes: aConstraint) ifFalse: [ constraints add: aConstraint ]
]

{ #category : 'accessing' }
CFPhysicsIsland >> bodies [
	^ bodies asArray
]

{ #category : 'accessing' }
CFPhysicsIsland >> constraints [
	^ constraints asArray
]

{ #category : 'accessing' }
CFPhysicsIsland >> dynamicBodies [
	^ self bodies select: #isDynamic
]

{ #category : 'accessing' }
CFPhysicsIsland >> kinematicBodies [
	^ self bodies select: #isKinematic
]

{ #category : 'accessing' }
CFPhysicsIsland >> staticBodies [
	^ self bodies select: #isStatic
]

{ #category : 'ordering' }
CFPhysicsIsland >> firstDynamicSequence [
	^ self dynamicBodies first sequence
]

{ #category : 'persistent islands' }
CFPhysicsIsland >> identifier [
	^ identifier
]

{ #category : 'persistent islands' }
CFPhysicsIsland >> identifier: anInteger [
	identifier := anInteger
]

{ #category : 'persistent islands' }
CFPhysicsIsland >> parentIsland [
	^ parentIsland
]

{ #category : 'persistent islands' }
CFPhysicsIsland >> parentIsland: anIslandOrNil [
	parentIsland := anIslandOrNil
]

{ #category : 'persistent islands' }
CFPhysicsIsland >> constraintRemoveCount [
	^ constraintRemoveCount
]

{ #category : 'persistent islands' }
CFPhysicsIsland >> noteConstraintRemoved [
	constraintRemoveCount := constraintRemoveCount + 1
]

{ #category : 'persistent islands' }
CFPhysicsIsland >> mergeFrom: anIsland [
	anIsland bodies do: [ :body | self addBody: body ].
	anIsland constraints do: [ :constraint | self addConstraint: constraint ].
	constraintRemoveCount := constraintRemoveCount + anIsland constraintRemoveCount
]

{ #category : 'persistent islands' }
CFPhysicsIsland >> removeConstraint: aConstraint [
	(constraints remove: aConstraint ifAbsent: [ nil ]) ifNotNil: [ self noteConstraintRemoved ]
]

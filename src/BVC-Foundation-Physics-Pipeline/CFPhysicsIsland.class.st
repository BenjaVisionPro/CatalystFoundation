Class {
	#name : 'CFPhysicsIsland',
	#superclass : 'Object',
	#instVars : [ 'bodies', 'constraints' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsIsland >> initialize [
	super initialize.
	bodies := OrderedCollection new.
	constraints := OrderedCollection new
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

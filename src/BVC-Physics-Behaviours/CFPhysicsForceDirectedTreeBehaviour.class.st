"I specialise force-directed graph orchestration for directed trees.

I use edge distance joints and many-body repulsion from my superclass, while attracting each body toward the graph centre as the D3 force-directed tree reference does with its x and y forces."
Class {
	#name : 'CFPhysicsForceDirectedTreeBehaviour',
	#superclass : 'CFPhysicsForceDirectedBehaviour',
	#instVars : [ 'attractionStiffness' ],
	#category : 'BVC-Physics-Behaviours',
	#package : 'BVC-Physics-Behaviours'
}

{ #category : 'initialization' }
CFPhysicsForceDirectedTreeBehaviour >> initialize [
	super initialize.
	attractionStiffness := CFPhysicsSharedScalar value: 0.012.
	self
		length: 80.0;
		hertz: 1.0;
		dampingRatio: 1.0;
		repulsionAtOneMetre: 0.45;
		maximumRepulsionDistance: 6.5;
		linearDamping: 1.25
]

{ #category : 'configuration' }
CFPhysicsForceDirectedTreeBehaviour >> attractionStiffness [
	"Point-attraction stiffness in newtons per metre."
	^ attractionStiffness value
]

{ #category : 'configuration' }
CFPhysicsForceDirectedTreeBehaviour >> attractionStiffness: aNumber [
	attractionStiffness value: (aNumber asFloat max: 0.0)
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedTreeBehaviour >> ensurePositioningForceFor: currentBodies [
	(positioningForce isNil or: [ positioningForce isActive not ]) ifTrue: [
		positioningForce := self world addForce: (CFPhysicsPointAttractionForce new wakesBodies: false) ].
	positioningForce
		bodies: currentBodies;
		point: self world owner extent / 2.0;
		stiffness: attractionStiffness value
]

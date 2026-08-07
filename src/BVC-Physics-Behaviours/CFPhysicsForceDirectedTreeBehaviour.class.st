"I specialise force-directed graph orchestration for directed trees.

I use edge distance joints and many-body repulsion from my superclass, while attracting each body toward the graph centre as the D3 force-directed tree reference does with its x and y forces."
Class {
	#name : 'CFPhysicsForceDirectedTreeBehaviour',
	#superclass : 'CFPhysicsForceDirectedBehaviour',
	#instVars : [ 'attractionStrength' ],
	#category : 'BVC-Physics-Behaviours',
	#package : 'BVC-Physics-Behaviours'
}

{ #category : 'initialization' }
CFPhysicsForceDirectedTreeBehaviour >> initialize [
	super initialize.
	attractionStrength := CFPhysicsSharedScalar value: 120.0.
	self
		length: 0.0;
		hertz: 1.0;
		dampingRatio: 1.0;
		repulsion: 900000.0;
		repulsionSofteningDistance: 72.0;
		maximumRepulsionDistance: 650.0;
		linearDamping: 1.25
]

{ #category : 'configuration' }
CFPhysicsForceDirectedTreeBehaviour >> attractionStrength [
	^ attractionStrength value
]

{ #category : 'configuration' }
CFPhysicsForceDirectedTreeBehaviour >> attractionStrength: aNumber [
	attractionStrength value: (aNumber asFloat max: 0.0)
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedTreeBehaviour >> ensurePositioningForceFor: currentBodies [
	(positioningForce isNil or: [ positioningForce isActive not ]) ifTrue: [
		positioningForce := self world addForce: (CFPhysicsPointAttractionForce new wakesBodies: false) ].
	positioningForce
		bodies: currentBodies;
		point: self world owner extent / 2.0;
		strength: attractionStrength value
]

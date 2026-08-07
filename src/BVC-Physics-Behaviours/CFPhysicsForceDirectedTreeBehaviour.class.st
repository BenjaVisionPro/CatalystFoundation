
"I specialise force-directed graph orchestration for directed trees.

I use the same graph adapter and Physics implementation as my superclass, with defaults tuned for compact parent-child structure."
Class {
	#name : 'CFPhysicsForceDirectedTreeBehaviour',
	#superclass : 'CFPhysicsForceDirectedBehaviour',
	#category : 'BVC-Physics-Behaviours',
	#package : 'BVC-Physics-Behaviours'
}

{ #category : 'initialization' }
CFPhysicsForceDirectedTreeBehaviour >> initialize [
	super initialize.
	self
		length: 42.0;
		hertz: 6.0;
		dampingRatio: 1.0;
		repulsion: 125000.0;
		repulsionSofteningDistance: 42.0;
		maximumRepulsionDistance: 220.0;
		centringStrength: 5.0;
		velocityDamping: 10.0
]

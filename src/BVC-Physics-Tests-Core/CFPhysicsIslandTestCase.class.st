Class {
	#name : 'CFPhysicsIslandTestCase',
	#superclass : 'CFPhysicsContactTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'private - islands' }
CFPhysicsIslandTestCase >> newConstraintBetween: firstBody and: secondBody [
	| contact |
	contact := CFPhysicsContact
		pair: (CFPhysicsPair first: firstBody second: secondBody)
		manifold: (self newManifoldWithFeatureIndex: secondBody sequence).
	^ CFPhysicsPreparedConstraint new
		contact: contact;
		points: #();
		yourself
]

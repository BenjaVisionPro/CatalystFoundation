Class {
	#name : 'CFPhysicsForceTests',
	#superclass : 'CFPhysicsTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - wind' }
CFPhysicsForceTests >> testWindAppliesTheConfiguredForceToEveryBody [
	| first second wind |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	second := self newBodyWithSequence: 2 position: 20 @ 0 extent: 10 @ 10.
	first beDynamic.
	second beDynamic.
	wind := CFPhysicsWindForce new
		bodies: { first. second };
		force: 30 @ -10;
		yourself.
	wind applyForStep: 0.016.
	self assert: first force equals: 30 @ -10.
	self assert: second force equals: 30 @ -10
]

{ #category : 'tests - centre' }
CFPhysicsForceTests >> testCentreForceMovesAGroupTowardItsConfiguredCentre [
	| first second centre |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	second := self newBodyWithSequence: 2 position: 20 @ 0 extent: 10 @ 10.
	first beDynamic.
	second beDynamic.
	centre := CFPhysicsCentreForce new
		bodies: { first. second };
		centre: 25 @ 5;
		strength: 2;
		yourself.
	centre applyForStep: 0.016.
	self assert: first force equals: 20 @ 0.
	self assert: second force equals: 20 @ 0
]

{ #category : 'tests - vortex' }
CFPhysicsForceTests >> testVortexAppliesTangentialForceAroundItsCentre [
	| body vortex |
	body := self newBodyWithSequence: 1 position: 15 @ -5 extent: 10 @ 10.
	body beDynamic.
	vortex := CFPhysicsVortexForce new
		bodies: { body };
		centre: 0 @ 0;
		force: 40;
		yourself.
	vortex applyForStep: 0.016.
	self assert: body force equals: 0 @ 40
]

{ #category : 'tests - membership' }
CFPhysicsForceTests >> testBodyForceDropsARetiredBodyWithoutDroppingOtherBodies [
	| first second wind |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	wind := CFPhysicsWindForce new bodies: { first. second }; yourself.
	wind removeBody: first.
	self deny: (wind includesBody: first).
	self assert: (wind includesBody: second)
]

{ #category : 'tests - many body' }
CFPhysicsForceTests >> testManyBodyRepulsionAppliesEqualAndOppositeForces [
	| first second repulsion |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	second := self newBodyWithSequence: 2 position: 20 @ 0 extent: 10 @ 10.
	first beDynamic.
	second beDynamic.
	repulsion := CFPhysicsManyBodyRepulsionForce new
		bodies: { first. second };
		force: 40;
		yourself.
	repulsion applyForStep: 0.016.
	self assert: first force equals: -40 @ 0.
	self assert: second force equals: 40 @ 0
]

{ #category : 'tests - point attraction' }
CFPhysicsForceTests >> testPointAttractionPullsEachBodyTowardTheConfiguredPoint [
	| first second attraction |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	second := self newBodyWithSequence: 2 position: 20 @ 0 extent: 10 @ 10.
	first beDynamic.
	second beDynamic.
	attraction := CFPhysicsPointAttractionForce new
		bodies: { first. second };
		point: 15 @ 5;
		strength: 2;
		yourself.
	attraction applyForStep: 0.016.
	self assert: first force equals: 20 @ 0.
	self assert: second force equals: -20 @ 0
]

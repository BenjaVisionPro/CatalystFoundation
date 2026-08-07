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
	self assert: first forceInNewtons equals: 30 @ -10.
	self assert: second forceInNewtons equals: 30 @ -10
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
		stiffness: 2;
		yourself.
	centre applyForStep: 0.016.
	self assert: first forceInNewtons equals: 0.2 @ 0.
	self assert: second forceInNewtons equals: 0.2 @ 0
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
	self assert: body forceInNewtons equals: 0 @ 40
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
	self assert: first forceInNewtons equals: -40 @ 0.
	self assert: second forceInNewtons equals: 40 @ 0
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
		stiffness: 2;
		yourself.
	attraction applyForStep: 0.016.
	self assert: first forceInNewtons equals: 0.2 @ 0.
	self assert: second forceInNewtons equals: -0.2 @ 0
]

{ #category : 'tests - units' }
CFPhysicsForceTests >> testOneNewtonAcceleratesOneKilogramByOneMetrePerSecondSquared [
	| owner element world body state |
	owner := BlElement new size: 300 @ 300; yourself.
	element := BlElement new size: 100 @ 100; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world containment disable.
	world gravity: 0 @ 0.
	element physics
		beDynamic;
		density: 1.0.
	body := element physics body.
	self assert: (body mass closeTo: 1.0).
	body applyForce: 1 @ 0.
	state := CFPhysicsBodyStepState on: body.
	state integrateVelocityBy: 1.0 gravity: 0 @ 0.
	self assert: (state linearVelocity x closeTo: 100.0).
	self assert: (world metresForLengthUnits: state linearVelocity x) closeTo: 1.0
]

{ #category : 'tests - units' }
CFPhysicsForceTests >> testPhysicalForceIsIndependentOfWorldLengthScale [
	| owner element world body state |
	owner := BlElement new size: 600 @ 600; yourself.
	element := BlElement new size: 200 @ 200; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world lengthUnitsPerMetre: 200.0.
	world containment disable.
	world gravity: 0 @ 0.
	element physics
		beDynamic;
		density: 1.0.
	body := element physics body.
	self assert: (body mass closeTo: 1.0).
	body applyForce: 1 @ 0.
	state := CFPhysicsBodyStepState on: body.
	state integrateVelocityBy: 1.0 gravity: 0 @ 0.
	self assert: (state linearVelocity x closeTo: 200.0).
	self assert: (world metresForLengthUnits: state linearVelocity x) closeTo: 1.0
]

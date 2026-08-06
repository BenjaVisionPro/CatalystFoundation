Class {
	#name : 'CFPhysicsBodyTests',
	#superclass : 'CFPhysicsTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - body types' }
CFPhysicsBodyTests >> testChangingBodyTypeDoesNotWakeContactNeighbours [
	<gtExample>
	| first second contact |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	contact := CFPhysicsContact
		pair: (CFPhysicsPair first: first second: second)
		manifold: nil.
	first addContact: contact.
	second addContact: contact.
	second sleep.
	self assert: second isSleeping.
	first beStatic.
	self assert: second isSleeping.
	first beDynamic.
	self assert: second isSleeping.
	^ first
]
{ #category : 'tests - body types' }
CFPhysicsBodyTests >> testStaticToDynamicCreatesContactWithoutMovement [
	<gtExample>
	| owner first second world firstBody secondBody firstResult secondResult |
	owner := BlElement new size: 200 @ 200; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world containment disable.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	firstBody := world bodyStateFor: first.
	secondBody := world bodyStateFor: second.
	firstBody position: 0 @ 0; beStatic.
	secondBody position: 10 @ 0; beStatic.
	firstResult := world step.
	self assert: firstResult activeContacts isEmpty.
	firstBody beDynamic.
	secondResult := world step.
	self assert: secondResult beganContacts size equals: 1.
	self assert: secondResult activeContacts size equals: 1.
	^ secondResult
]
{ #category : 'tests - body types' }
CFPhysicsBodyTests >> testDynamicToStaticEndsContactAndRemovesPersistentConnectivity [
	<gtExample>
	| owner first second world firstBody secondBody firstResult contact secondResult |
	owner := BlElement new size: 200 @ 200; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world containment disable.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	firstBody := world bodyStateFor: first.
	secondBody := world bodyStateFor: second.
	firstBody position: 0 @ 0.
	secondBody position: 10 @ 0; beStatic.
	firstResult := world step.
	contact := firstResult activeContacts first.
	self assert: (world persistentIslandGraph islandForConstraint: contact) notNil.
	firstBody beStatic.
	self assert: (world persistentIslandGraph islandForConstraint: contact) isNil.
	self assert: (world persistentIslandGraph islandForBody: firstBody) isNil.
	secondResult := world step.
	self assert: secondResult endedContacts size equals: 1.
	self assert: secondResult activeContacts isEmpty.
	^ secondResult
]
{ #category : 'tests - body types' }
CFPhysicsBodyTests >> testBodyTypeChangeReconcilesPersistentIslandMembership [
	<gtExample>
	| owner element world body |
	owner := BlElement new size: 200 @ 200; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world containment disable.
	world owner physics makeChildrenDynamic.
	body := world bodyStateFor: element.
	self assert: (world persistentIslandGraph islandForBody: body) notNil.
	body beStatic.
	self assert: (world persistentIslandGraph islandForBody: body) isNil.
	body beKinematic.
	self assert: (world persistentIslandGraph islandForBody: body) notNil.
	body beDynamic.
	self assert: (world persistentIslandGraph islandForBody: body) notNil.
	^ body
]
{ #category : 'tests - body types' }
CFPhysicsBodyTests >> testKinematicBodyIntegratesItsPrescribedVelocityWithoutForces [
	<gtExample>
	| body state |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	body
		beKinematic;
		velocity: 4 @ -2;
		angularVelocity: 0.5;
		linearDamping: 10.0;
		angularDamping: 10.0;
		applyForce: 1000 @ 1000;
		applyTorque: 1000.
	state := CFPhysicsBodyStepState on: body.
	state integrateVelocityBy: 2.0 gravity: 0 @ 100.
	self assert: state linearVelocity equals: 4 @ -2.
	self assert: (state angularVelocity closeTo: 0.5).
	state integratePositionBy: 2.0.
	state commit.
	self assert: (body position closeTo: 8 @ -4).
	self assert: (body rotation closeTo: 1.0).
	^ body
]
{ #category : 'tests - body types' }
CFPhysicsBodyTests >> testKinematicBodyHasInfiniteMassAndCannotSleep [
	<gtExample>
	| body |
	body := self newBodyWithSequence: 1.
	body beKinematic.
	self assert: body isKinematic.
	self assert: body isDynamic not.
	self assert: body isStatic not.
	self assert: body inverseMass equals: 0.0.
	self assert: body inverseInertia equals: 0.0.
	body sleep.
	self assert: body isAwake.
	self assert: body isSleeping not.
	^ body
]
{ #category : 'tests - body types' }
CFPhysicsBodyTests >> testBroadphaseRequiresADynamicBodyInKinematicPairs [
	<gtExample>
	| dynamic kinematic static finder pairs |
	dynamic := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	kinematic := self newBodyWithSequence: 2 position: 0 @ 0 extent: 20 @ 20.
	static := self newBodyWithSequence: 3 position: 0 @ 0 extent: 20 @ 20.
	kinematic beKinematic.
	static beStatic.
	finder := CFPhysicsPairFinder new.
	pairs := finder pairsAmong: { static. kinematic. dynamic }.
	self assert: pairs size equals: 2.
	self assert: (pairs anySatisfy: [ :pair |
		pair firstBody == dynamic and: [ pair secondBody == kinematic ] ]).
	self assert: (pairs anySatisfy: [ :pair |
		pair firstBody == dynamic and: [ pair secondBody == static ] ]).
	self assert: (pairs anySatisfy: [ :pair |
		(pair firstBody == kinematic and: [ pair secondBody == static ]) or: [
			pair firstBody == static and: [ pair secondBody == kinematic ] ] ]) not.
	^ pairs
]
{ #category : 'tests - body types' }
CFPhysicsBodyTests >> testPhysicsFacadeExposesBodyTypeThroughIntentQueries [
	<gtExample>
	| owner element world physics |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	physics := element physics beDynamic.
	self assert: physics isDynamic.
	physics beKinematic.
	self assert: physics isKinematic.
	physics beStatic.
	self assert: physics isStatic.
	^ physics
]

{ #category : 'tests - public api' }
CFPhysicsBodyTests >> testPhysicsFacadeConfiguresContinuousCollision [
	<gtExample>
	| owner element world physics |
	owner := BlElement new size: 200 @ 200; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	physics := element physics beDynamic.
	self deny: physics isBullet.
	self assert: physics beBullet == physics.
	self assert: physics isBullet.
	self assert: physics beNonBullet == physics.
	self deny: physics isBullet.
	^ physics
]

{ #category : 'tests - public api' }
CFPhysicsBodyTests >> testPhysicsFacadeAppliesImpulseAtTheBodyCentre [
	<gtExample>
	| owner element world physics |
	owner := BlElement new size: 200 @ 200; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	physics := element physics beDynamic.
	physics applyImpulse: 10 @ 0.
	self assert: physics velocity x > 0.
	self assert: physics angularVelocity equals: 0.0.
	^ physics
]

{ #category : 'tests - public api' }
CFPhysicsBodyTests >> testPhysicsFacadeAppliesImpulseAtAWorldPoint [
	<gtExample>
	| owner element world physics point |
	owner := BlElement new size: 200 @ 200; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	physics := element physics beDynamic.
	point := physics body worldBodyOrigin + (0 @ 10).
	physics applyImpulse: 10 @ 0 atWorldPoint: point.
	self assert: physics velocity x > 0.
	self deny: physics angularVelocity equals: 0.0.
	^ physics
]

{ #category : 'tests - public api' }
CFPhysicsBodyTests >> testPhysicsFacadeConfigurationIsFluent [
	<gtExample>
	| owner element physics |
	owner := BlElement new size: 200 @ 200; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	owner physics beWorld.
	physics := element physics beDynamic.
	self assert: (physics
		density: 2;
		friction: 0.3;
		restitution: 0.5;
		rollingResistance: 0.1;
		tangentSpeed: 1;
		position: 40 @ 30;
		rotation: 0.2;
		velocity: 2 @ 1;
		addVelocity: 1 @ 0;
		linearDamping: 0.1;
		angularDamping: 0.2;
		gravityScale: 0.5;
		sleepThreshold: 0.05;
		allowSleeping;
		wake;
		beSensor;
		beSolid;
		collisionCategoryBits: 2;
		collisionMaskBits: 3;
		collisionGroupIndex: 0;
		applyAngularImpulse: 0;
		clearForces) == physics.
	^ physics
]

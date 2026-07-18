Class {
	#name : 'CFPhysicsSteppingExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'examples - stepping' }
CFPhysicsSteppingExamples >> dynamicBodyAdvancesUnderGravity [
	<gtExample>
	| owner body world expectedPosition expectedVelocity |
	owner := BlElement new.
	body := BlElement new.
	owner addChild: body.
	world := owner physics beWorld.
	body physics.
	world stepDuration: 10 milliseconds.
	world gravity: 0 @ 100.
	world step: 2.
	expectedVelocity := 0 @ 2.
	expectedPosition := 0 @ 0.03.
	self assert: (body physics velocity x closeTo: expectedVelocity x).
	self assert: (body physics velocity y closeTo: expectedVelocity y).
	self assert: (body physics position x closeTo: expectedPosition x).
	self assert: (body physics position y closeTo: expectedPosition y).
	^ body
]

{ #category : 'examples - stepping' }
CFPhysicsSteppingExamples >> staticBodyDoesNotAdvance [
	<gtExample>
	| owner body world |
	owner := BlElement new.
	body := BlElement new.
	owner addChild: body.
	world := owner physics beWorld.
	body physics beStatic.
	body physics position: 10 @ 20.
	body physics velocity: 30 @ 40.
	world step: 5.
	self assert: body physics isStatic.
	self assert: body physics position equals: 10 @ 20.
	self assert: body physics velocity equals: 0 @ 0.
	^ body
]

{ #category : 'examples - stepping' }
CFPhysicsSteppingExamples >> worldOwnerCanRemainBodyOfAncestorWorld [
	<gtExample>
	| outer nested outerWorld nestedWorld |
	outer := BlElement new.
	nested := BlElement new.
	outer addChild: nested.
	outerWorld := outer physics beWorld.
	nestedWorld := nested physics beWorld.
	outerWorld synchroniseMembership.
	nestedWorld synchroniseMembership.
	nested physics velocity: 5 @ 0.
	outerWorld gravity: 0 @ 0.
	outerWorld stepDuration: 10 milliseconds.
	outerWorld step.
	self assert: nested physics bodyState world == outerWorld.
	self assert: nested physics position equals: 0.05 @ 0.
	^ nested
]

{ #category : 'examples - collision' }
CFPhysicsSteppingExamples >> dynamicRectangleStopsOnStaticRectangle [
	<gtExample>
	| owner body ground world |
	owner := BlElement new.
	body := BlElement new size: 20 @ 20; yourself.
	ground := BlElement new size: 100 @ 20; yourself.
	owner addChild: body.
	owner addChild: ground.
	world := owner physics beWorld.
	body physics position: 10 @ 0.
	ground physics
		beStatic;
		position: 0 @ 40.
	world
		stepDuration: 10 milliseconds;
		gravity: 0 @ 100;
		step: 100.
	self assert: (body physics position x closeTo: 10.0).
	self assert: (body physics position y closeTo: 20.0).
	self assert: (body physics velocity x closeTo: 0.0).
	self assert: (body physics velocity y closeTo: 0.0).
	self assert: world contacts size equals: 1.
	self assert: world contacts first normal equals: 0 @ 1.
	^ body
]

{ #category : 'examples - collision' }
CFPhysicsSteppingExamples >> separatedRectanglesProduceNoContact [
	<gtExample>
	| owner first second world |
	owner := BlElement new.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChild: first.
	owner addChild: second.
	world := owner physics beWorld.
	first physics position: 0 @ 0.
	second physics
		beStatic;
		position: 100 @ 100.
	world gravity: 0 @ 0.
	world step.
	self assert: world contacts isEmpty.
	^ world
]

{ #category : 'examples - collision' }
CFPhysicsSteppingExamples >> shapeStateUsesElementExtent [
	<gtExample>
	| owner body world shape |
	owner := BlElement new.
	body := BlElement new size: 30 @ 40; yourself.
	owner addChild: body.
	world := owner physics beWorld.
	world synchroniseMembership.
	shape := body physics bodyState shapeState.
	self assert: shape extent equals: 30 @ 40.
	^ shape
]

{ #category : 'examples - contacts' }
CFPhysicsSteppingExamples >> sameContactInstanceSurvivesAcrossSteps [
	<gtExample>
	| owner body ground world contact |
	owner := BlElement new.
	body := BlElement new size: 20 @ 20; yourself.
	ground := BlElement new size: 100 @ 20; yourself.
	owner addChild: body.
	owner addChild: ground.
	world := owner physics beWorld.
	body physics position: 10 @ 0.
	ground physics beStatic; position: 0 @ 40.
	world stepDuration: 10 milliseconds; gravity: 0 @ 100; step: 100.
	contact := world contacts first.
	world step.
	self assert: world contacts first == contact.
	self assert: contact continuedThisStep.
	^ contact
]

{ #category : 'examples - contacts' }
CFPhysicsSteppingExamples >> bodyKnowsItsContacts [
	<gtExample>
	| contact |
	contact := self sameContactInstanceSurvivesAcrossSteps.
	self assert: (contact firstBody contacts includes: contact).
	self assert: (contact secondBody contacts includes: contact).
	^ contact firstBody
]

{ #category : 'examples - contacts' }
CFPhysicsSteppingExamples >> contactEndsAfterSeparation [
	<gtExample>
	| owner body ground world contact |
	owner := BlElement new.
	body := BlElement new size: 20 @ 20; yourself.
	ground := BlElement new size: 100 @ 20; yourself.
	owner addChild: body.
	owner addChild: ground.
	world := owner physics beWorld.
	body physics position: 10 @ 0.
	ground physics beStatic; position: 0 @ 40.
	world stepDuration: 10 milliseconds; gravity: 0 @ 100; step: 100.
	contact := world contacts first.
	world gravity: 0 @ 0.
	body physics position: 200 @ 0.
	world step.
	self assert: world contacts isEmpty.
	self assert: world endedContacts size equals: 1.
	self assert: world endedContacts first == contact.
	self assert: contact endedThisStep.
	self assert: (contact firstBody contacts includes: contact) not.
	self assert: (contact secondBody contacts includes: contact) not.
	^ contact
]

{ #category : 'examples - contacts' }
CFPhysicsSteppingExamples >> contactOwnsManifold [
	<gtExample>
	| contact |
	contact := self sameContactInstanceSurvivesAcrossSteps.
	self assert: contact manifold notNil.
	self assert: contact normal equals: contact manifold normal.
	self assert: contact penetration equals: contact manifold penetration.
	^ contact manifold
]

{ #category : 'examples - collision' }
CFPhysicsSteppingExamples >> circleShapeUsesInscribedRadius [
	<gtExample>
	| owner circle world shape |
	owner := BlElement new.
	circle := BlElement new
		geometry: BlCircleGeometry new;
		size: 30 @ 40;
		yourself.
	owner addChild: circle.
	world := owner physics beWorld.
	world synchroniseMembership.
	shape := circle physics bodyState shapeState.
	self assert: shape isCircle.
	self assert: shape radius equals: 15.
	self assert: shape aabb extent equals: 30 @ 30.
	^ shape
]

{ #category : 'examples - collision' }
CFPhysicsSteppingExamples >> dynamicCircleStopsOnStaticRectangle [
	<gtExample>
	| owner ball ground world contact |
	owner := BlElement new.
	ball := BlElement new
		geometry: BlCircleGeometry new;
		size: 20 @ 20;
		yourself.
	ground := BlElement new size: 100 @ 20; yourself.
	owner addChild: ball.
	owner addChild: ground.
	world := owner physics beWorld.
	ball physics position: 10 @ 0.
	ground physics beStatic; position: 0 @ 40.
	world stepDuration: 10 milliseconds; gravity: 0 @ 100; step: 100.
	contact := world contacts first.
	self assert: (ball physics position x closeTo: 10.0).
	self assert: (ball physics position y closeTo: 20.0).
	self assert: (ball physics velocity x closeTo: 0.0).
	self assert: (ball physics velocity y closeTo: 0.0).
	self assert: contact normal equals: 0 @ 1.
	self assert: contact manifold points size equals: 1.
	^ contact
]

{ #category : 'examples - collision' }
CFPhysicsSteppingExamples >> overlappingCirclesProduceExactManifold [
	<gtExample>
	| owner first second world contact |
	owner := BlElement new.
	first := BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself.
	second := BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself.
	owner addChild: first.
	owner addChild: second.
	world := owner physics beWorld.
	first physics position: 0 @ 0.
	second physics beStatic; position: 15 @ 0.
	world gravity: 0 @ 0; step.
	contact := world contacts first.
	self assert: contact normal equals: 1 @ 0.
	self assert: (contact penetration closeTo: 0.0).
	self assert: (contact manifold points first x closeTo: 15.0).
	self assert: (contact manifold points first y closeTo: 10.0).
	self assert: (first physics position x closeTo: -5.0).
	self assert: (first physics position y closeTo: 0.0).
	^ contact
]

{ #category : 'examples - contacts' }
CFPhysicsSteppingExamples >> circleRectangleContactPersistsAcrossSteps [
	<gtExample>
	| owner ball ground world contact |
	owner := BlElement new.
	ball := BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself.
	ground := BlElement new size: 100 @ 20; yourself.
	owner addChild: ball.
	owner addChild: ground.
	world := owner physics beWorld.
	ball physics position: 10 @ 0.
	ground physics beStatic; position: 0 @ 40.
	world stepDuration: 10 milliseconds; gravity: 0 @ 100; step: 100.
	contact := world contacts first.
	world step.
	self assert: world contacts first == contact.
	self assert: contact continuedThisStep.
	^ contact
]

{ #category : 'examples - materials' }
CFPhysicsSteppingExamples >> cachedNormalImpulsePersistsAcrossSteps [
	<gtExample>
	| owner body ground world contact firstImpulse secondImpulse |
	owner := BlElement new.
	body := BlElement new size: 20 @ 20; yourself.
	ground := BlElement new size: 100 @ 20; yourself.
	owner addChild: body.
	owner addChild: ground.
	world := owner physics beWorld.
	body physics position: 10 @ 0.
	ground physics beStatic; position: 0 @ 40.
	world stepDuration: 10 milliseconds; gravity: 0 @ 100; step: 100.
	contact := world contacts first.
	firstImpulse := contact manifold contactPoints first normalImpulse.
	world step.
	secondImpulse := contact manifold contactPoints first normalImpulse.
	self assert: world contacts first == contact.
	self assert: firstImpulse > 0.
	self assert: secondImpulse > 0.
	^ contact
]

{ #category : 'examples - materials' }
CFPhysicsSteppingExamples >> restitutionProducesBounce [
	<gtExample>
	| owner ball ground world |
	owner := BlElement new.
	ball := BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself.
	ground := BlElement new size: 100 @ 20; yourself.
	owner addChild: ball.
	owner addChild: ground.
	world := owner physics beWorld.
	ball physics position: 10 @ 20.5; velocity: 0 @ 100; restitution: 1.0.
	ground physics beStatic; position: 0 @ 40; restitution: 1.0.
	world stepDuration: 10 milliseconds; gravity: 0 @ 0; step.
	self assert: ball physics velocity y < 0.
	^ ball
]

{ #category : 'examples - materials' }
CFPhysicsSteppingExamples >> frictionReducesTangentialVelocity [
	<gtExample>
	| owner body ground world |
	owner := BlElement new.
	body := BlElement new size: 20 @ 20; yourself.
	ground := BlElement new size: 100 @ 20; yourself.
	owner addChild: body.
	owner addChild: ground.
	world := owner physics beWorld.
	body physics position: 10 @ 20; velocity: 100 @ 0; friction: 1.0.
	ground physics beStatic; position: 0 @ 40; friction: 1.0.
	world stepDuration: 10 milliseconds; gravity: 0 @ 100; step.
	self assert: body physics velocity x abs < 100.
	^ body
]

{ #category : 'examples - materials' }
CFPhysicsSteppingExamples >> materialValuesBelongToShape [
	<gtExample>
	| owner body world material |
	owner := BlElement new.
	body := BlElement new size: 20 @ 30; yourself.
	owner addChild: body.
	world := owner physics beWorld.
	body physics density: 2; friction: 0.7; restitution: 0.4.
	material := body physics bodyState shapeState material.
	self assert: material density equals: 2.0.
	self assert: material friction equals: 0.7.
	self assert: material restitution equals: 0.4.
	^ material
]


{ #category : 'examples - solver' }
CFPhysicsSteppingExamples >> worldExposesSolverIterations [
	<gtExample>
	| owner world |
	owner := BlElement new.
	world := owner physics beWorld.
	world velocityIterations: 6; positionIterations: 2.
	self assert: world velocityIterations equals: 6.
	self assert: world positionIterations equals: 2.
	^ world
]

{ #category : 'examples - sleeping' }
CFPhysicsSteppingExamples >> settledBodyGoesToSleep [
	<gtExample>
	| owner body ground world |
	owner := BlElement new.
	body := BlElement new size: 20 @ 20; yourself.
	ground := BlElement new size: 100 @ 20; yourself.
	owner addChild: body.
	owner addChild: ground.
	world := owner physics beWorld.
	body physics position: 10 @ 0.
	ground physics beStatic; position: 0 @ 40.
	world
		stepDuration: 10 milliseconds;
		gravity: 0 @ 100;
		sleepTimeThreshold: 100 milliseconds;
		step: 120.
	self assert: body physics isSleeping.
	self assert: body physics velocity equals: 0 @ 0.
	^ body
]

{ #category : 'examples - sleeping' }
CFPhysicsSteppingExamples >> assigningVelocityWakesSleepingBody [
	<gtExample>
	| body |
	body := self settledBodyGoesToSleep.
	body physics velocity: 10 @ 0.
	self assert: body physics isAwake.
	self assert: body physics velocity equals: 10 @ 0.
	^ body
]

{ #category : 'examples - solver' }
CFPhysicsSteppingExamples >> twoBodyStackRemainsOrdered [
	<gtExample>
	| owner lower upper ground world |
	owner := BlElement new.
	lower := BlElement new size: 20 @ 20; yourself.
	upper := BlElement new size: 20 @ 20; yourself.
	ground := BlElement new size: 100 @ 20; yourself.
	owner addChild: lower; addChild: upper; addChild: ground.
	world := owner physics beWorld.
	lower physics position: 10 @ 10.
	upper physics position: 10 @ -15.
	ground physics beStatic; position: 0 @ 40.
	world stepDuration: 10 milliseconds; gravity: 0 @ 100; step: 180.
	self assert: upper physics position y < lower physics position y.
	self assert: world contacts size equals: 2.
	^ owner
]

{ #category : 'examples - polygon collision' }
CFPhysicsSteppingExamples >> convexPolygonShapeUsesItsVertices [
	<gtExample>
	| owner polygon world shape |
	owner := BlElement new.
	polygon := BlElement new
		geometry: (BlPolygonGeometry vertices: { 0 @ 20. 20 @ 0. 40 @ 20. 20 @ 40 });
		size: 40 @ 40;
		yourself.
	owner addChild: polygon.
	world := owner physics beWorld.
	world synchroniseMembership.
	shape := polygon physics bodyState shapeState.
	self assert: shape isPolygon.
	self assert: shape localCollisionVertices size equals: 4.
	self assert: shape area equals: 800.0.
	self assert: shape aabb extent equals: 40 @ 40.
	^ shape
]

{ #category : 'examples - polygon collision' }
CFPhysicsSteppingExamples >> dynamicPolygonStopsOnStaticRectangle [
	<gtExample>
	| owner polygon ground world contact |
	owner := BlElement new.
	polygon := BlElement new
		geometry: (BlPolygonGeometry vertices: { 0 @ 20. 20 @ 0. 40 @ 20. 20 @ 40 });
		size: 40 @ 40;
		yourself.
	ground := BlElement new size: 120 @ 20; yourself.
	owner addChild: polygon.
	owner addChild: ground.
	world := owner physics beWorld.
	polygon physics position: 20 @ 0.
	ground physics beStatic; position: 0 @ 60.
	world stepDuration: 10 milliseconds; gravity: 0 @ 100; step: 120.
	contact := world contacts first.
	self assert: (polygon physics position y closeTo: 20.0).
	self assert: contact normal equals: 0 @ 1.
	self assert: contact manifold points size equals: 1.
	^ contact
]

{ #category : 'examples - polygon collision' }
CFPhysicsSteppingExamples >> circleContactsConvexPolygon [
	<gtExample>
	| owner circle polygon world contact |
	owner := BlElement new.
	circle := BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself.
	polygon := BlElement new
		geometry: (BlPolygonGeometry vertices: { 0 @ 20. 20 @ 0. 40 @ 20. 20 @ 40 });
		size: 40 @ 40;
		yourself.
	owner addChild: circle.
	owner addChild: polygon.
	world := owner physics beWorld.
	circle physics position: 10 @ 10.
	polygon physics beStatic; position: 25 @ 0.
	world gravity: 0 @ 0; step.
	contact := world contacts first.
	self assert: contact manifold notNil.
	self assert: contact normal x > 0.
	^ contact
]


{ #category : 'examples - convex collision' }
CFPhysicsSteppingExamples >> roundedRectangleSupportPointUsesCornerArc [
	<gtExample>
	| owner body world shape point expected |
	owner := BlElement new.
	body := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 5);
		size: 40 @ 20;
		yourself.
	owner addChild: body.
	world := owner physics beWorld.
	world synchroniseMembership.
	shape := body physics bodyState shapeState.
	point := shape supportPointAt: 0 @ 0 inDirection: 1 @ 1.
	expected := 35 @ 15 + (((1 @ 1) / (1 @ 1) r) * 5).
	self assert: (point x closeTo: expected x).
	self assert: (point y closeTo: expected y).
	^ shape
]

{ #category : 'examples - convex collision' }
CFPhysicsSteppingExamples >> roundedRectanglesUseGeneralConvexCollision [
	<gtExample>
	| owner first second world contact |
	owner := BlElement new.
	first := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 5);
		size: 20 @ 20;
		yourself.
	second := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 5);
		size: 20 @ 20;
		yourself.
	owner addChild: first.
	owner addChild: second.
	world := owner physics beWorld.
	first physics position: 0 @ 0.
	second physics beStatic; position: 15 @ 0.
	world gravity: 0 @ 0; step.
	contact := world contacts first.
	self assert: contact manifold notNil.
	self assert: contact penetration >= 0.
	self assert: contact normal x > 0.
	^ contact
]


{ #category : 'examples - convex collision' }
CFPhysicsSteppingExamples >> separatedRoundedRectanglesDoNotProduceManifold [
	<gtExample>
	| owner first second world manifold |
	owner := BlElement new.
	first := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 12);
		size: 50 @ 50;
		yourself.
	second := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		size: 400 @ 40;
		yourself.
	owner addChild: first.
	owner addChild: second.
	world := owner physics beWorld.
	first physics position: 100 @ 149.999999999.
	second physics beStatic; position: 0 @ 200.
	world synchroniseMembership.
	self assert: (first physics bodyState aabb overlaps: second physics bodyState aabb) not.
	manifold := CFPhysicsConvexCollision
		manifoldBetween: first physics bodyState
		and: second physics bodyState.
	self assert: manifold isNil.
	^ first
]


{ #category : 'examples - rotation collision' }
CFPhysicsSteppingExamples >> rotatedRectangleAABBUsesRotatedGeometry [
	<gtExample>
	| owner body world aabb |
	owner := BlElement new.
	body := BlElement new size: 40 @ 20; yourself.
	owner addChild: body.
	world := owner physics beWorld.
	body physics rotation: Float pi / 2.
	aabb := body physics bodyState aabb.
	self assert: (aabb extent x closeTo: 20.0).
	self assert: (aabb extent y closeTo: 40.0).
	^ aabb
]

{ #category : 'examples - rotation collision' }
CFPhysicsSteppingExamples >> rotatedRectangleProducesContact [
	<gtExample>
	| owner body ground world |
	owner := BlElement new.
	body := BlElement new size: 40 @ 20; yourself.
	ground := BlElement new size: 100 @ 20; yourself.
	owner addChild: body; addChild: ground.
	world := owner physics beWorld.
	body physics position: 30 @ 20; rotation: Float pi / 4.
	ground physics beStatic; position: 0 @ 40.
	world gravity: 0 @ 0; step.
	self assert: world contacts notEmpty.
	^ world contacts first
]

{ #category : 'examples - rotation collision' }
CFPhysicsSteppingExamples >> touchingRotatedRoundedRectangleHasNoFalsePenetration [
	<gtExample>
	| owner body ground world manifold touchingPosition |
	owner := BlElement new.
	body := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		size: 60 @ 30;
		yourself.
	ground := BlElement new size: 400 @ 40; yourself.
	owner addChild: body; addChild: ground.
	world := owner physics beWorld.
	touchingPosition := 100 @ 160.6698729810778.
	body physics
		position: touchingPosition;
		rotation: Float pi / 6.
	ground physics beStatic; position: 0 @ 200.
	manifold := CFPhysicsCollision
		manifoldBetween: body physics bodyState
		and: ground physics bodyState.
	self assert: manifold notNil.
	self assert: manifold penetration equals: 0.0.
	^ manifold
]



{ #category : 'private - diagnostics' }
CFPhysicsSteppingExamples >> physicsSleepingDiagnosticFor: anElement world: aWorld step: stepIndex [
	| state contacts contact points point |
	state := anElement physics bodyState.
	contacts := aWorld contacts.
	Transcript
		cr;
		nextPutAll: 'CFPhysics sleeping snapshot step='; print: stepIndex;
		nextPutAll: ' awake='; print: state isAwake;
		nextPutAll: ' sleeping='; print: state isSleeping;
		nextPutAll: ' sleepTime='; print: state sleepTime;
		nextPutAll: ' position='; print: state position;
		nextPutAll: ' rotation='; print: state rotation;
		nextPutAll: ' velocity='; print: state velocity;
		nextPutAll: ' speedSquared='; print: (state velocity x squared + state velocity y squared);
		nextPutAll: ' angularVelocity='; print: state angularVelocity;
		nextPutAll: ' angularSpeedSquared='; print: state angularVelocity squared;
		nextPutAll: ' contacts='; print: contacts size.
	contacts isEmpty ifTrue: [ ^ self ].
	contact := contacts first.
	Transcript
		nextPutAll: ' contactId='; print: contact identityHash;
		nextPutAll: ' touching='; print: contact isTouching;
		nextPutAll: ' normal='; print: contact normal;
		nextPutAll: ' penetration='; print: contact penetration.
	points := contact manifold contactPoints.
	points isEmpty ifTrue: [ ^ self ].
	point := points first.
	Transcript
		nextPutAll: ' point='; print: point position;
		nextPutAll: ' normalImpulse='; print: point normalImpulse;
		nextPutAll: ' tangentImpulse='; print: point tangentImpulse;
		nextPutAll: ' velocityBias='; print: point velocityBias
]

{ #category : 'examples - rotation collision' }
CFPhysicsSteppingExamples >> sleepingRotatedRoundedRectangleRetainsContact [
	<gtExample>
	| owner body ground world contact |
	owner := BlElement new.
	body := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		size: 60 @ 30;
		yourself.
	ground := BlElement new size: 400 @ 40; yourself.
	owner addChild: body; addChild: ground.
	world := owner physics beWorld.
	body physics
		position: 100 @ 80;
		rotation: Float pi / 6;
		angularDamping: 2.0.
	ground physics beStatic; position: 0 @ 200.
	world stepDuration: 10 milliseconds; gravity: 0 @ 600.
	Transcript cr; nextPutAll: '=== CFPhysics sleeping state diagnostic ==='.
	1 to: 600 do: [ :stepIndex |
		world step.
		((stepIndex \ 50) = 0 or: [ stepIndex > 540 ]) ifTrue: [
			self physicsSleepingDiagnosticFor: body world: world step: stepIndex ] ].
	Transcript cr; nextPutAll: '=== end CFPhysics sleeping state diagnostic ==='.
	self assert: body physics isSleeping.
	self assert: world contacts size equals: 1.
	contact := world contacts first.
	self assert: contact isTouching.
	^ contact
]

{ #category : 'examples - angular dynamics' }
CFPhysicsSteppingExamples >> torqueChangesAngularVelocity [
	<gtExample>
	| owner body world |
	owner := BlElement new.
	body := BlElement new size: 20 @ 40; yourself.
	owner addChild: body.
	world := owner physics beWorld.
	world gravity: 0 @ 0; stepDuration: 10 milliseconds.
	body physics applyTorque: 10000.
	world step.
	self assert: body physics angularVelocity > 0.
	self assert: body physics rotation > 0.
	^ body
]

{ #category : 'examples - angular dynamics' }
CFPhysicsSteppingExamples >> centredImpulseDoesNotRotateCircle [
	<gtExample>
	| owner circle world state |
	owner := BlElement new.
	circle := BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself.
	owner addChild: circle.
	world := owner physics beWorld.
	world synchroniseMembership.
	state := circle physics bodyState.
	state applyImpulse: 10 @ 0 atWorldPoint: state centre.
	self assert: state angularVelocity equals: 0.0.
	^ circle
]

{ #category : 'examples - angular dynamics' }
CFPhysicsSteppingExamples >> offCentreImpulseRotatesRectangle [
	<gtExample>
	| owner body world state |
	owner := BlElement new.
	body := BlElement new size: 20 @ 40; yourself.
	owner addChild: body.
	world := owner physics beWorld.
	world synchroniseMembership.
	state := body physics bodyState.
	state applyImpulse: 10 @ 0 atWorldPoint: state centre + (0 @ 10).
	self assert: state angularVelocity < 0.
	^ body
]

{ #category : 'examples - angular dynamics' }
CFPhysicsSteppingExamples >> staticBodyHasNoInverseInertia [
	<gtExample>
	| owner body world |
	owner := BlElement new.
	body := BlElement new size: 20 @ 40; yourself.
	owner addChild: body.
	world := owner physics beWorld.
	body physics beStatic.
	self assert: body physics inverseInertia equals: 0.0.
	^ body
]


{ #category : 'examples - angular dynamics' }
CFPhysicsSteppingExamples >> polygonGroundContactUsesBodyWitnessPoint [
	<gtExample>
	| owner polygon ground world contact centre contactPoint |
	owner := BlElement new.
	polygon := BlElement new
		geometry: (BlPolygonGeometry vertices: { 0 @ 0. 20 @ 0. 40 @ 20. 20 @ 40 });
		size: 40 @ 40;
		yourself.
	ground := BlElement new size: 120 @ 20; yourself.
	owner addChild: polygon; addChild: ground.
	world := owner physics beWorld.
	polygon physics position: 20 @ 21.
	ground physics beStatic; position: 0 @ 60.
	world gravity: 0 @ 0; step.
	contact := world contacts first.
	centre := polygon physics bodyState centre.
	contactPoint := contact manifold points first.
	self assert: (contactPoint x closeTo: centre x).
	^ contact
]

{ #category : 'examples - angular dynamics' }
CFPhysicsSteppingExamples >> roundedRectangleRestingContactDoesNotInjectAngularVelocity [
	<gtExample>
	| owner body ground world |
	owner := BlElement new.
	body := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		size: 60 @ 30;
		yourself.
	ground := BlElement new size: 400 @ 40; yourself.
	owner addChild: body; addChild: ground.
	world := owner physics beWorld.
	body physics position: 100 @ 170.
	ground physics beStatic; position: 0 @ 200.
	world gravity: 0 @ 0; step: 10.
	self assert: body physics angularVelocity abs <= world sleepAngularThreshold.
	^ body
]


{ #category : 'examples - angular dynamics' }
CFPhysicsSteppingExamples >> verticalRoundedRectangleSupportUsesFaceCentre [
	<gtExample>
	| element owner world state point |
	owner := BlElement new.
	element := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		size: 60 @ 30;
		yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world synchroniseMembership.
	state := element physics bodyState.
	point := state shapeState
		supportPointAt: 0 @ 0
		rotation: 0
		inDirection: 0 @ 1.
	self assert: point equals: 30 @ 30.
	^ point
]



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
	self assert: (body physics velocity distanceTo: expectedVelocity) < 0.000001.
	self assert: (body physics position distanceTo: expectedPosition) < 0.000001.
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
	self assert: (body physics position distanceTo: 10 @ 20) < 0.000001.
	self assert: (body physics velocity distanceTo: 0 @ 0) < 0.000001.
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
	self assert: (ball physics position distanceTo: 10 @ 20) < 0.000001.
	self assert: (ball physics velocity distanceTo: 0 @ 0) < 0.000001.
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
	self assert: contact penetration equals: 5.
	self assert: contact manifold points first equals: 20 @ 10.
	self assert: first physics position equals: -5 @ 0.
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

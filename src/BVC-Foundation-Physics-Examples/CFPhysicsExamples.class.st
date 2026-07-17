Class {
	#name : 'CFPhysicsExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
}

{ #category : 'examples - worlds' }
CFPhysicsExamples >> nestedPhysicsWorlds [
	<gtExample>
	| root outerBody nestedWorldElement nestedBody outerWorld nestedWorld |
	root := BlElement new.
	outerBody := BlElement new.
	nestedWorldElement := BlElement new.
	nestedBody := BlElement new.
	root addChild: outerBody.
	root addChild: nestedWorldElement.
	nestedWorldElement addChild: nestedBody.
	outerWorld := root physics beWorld.
	nestedWorld := nestedWorldElement physics beWorld.
	outerBody physics.
	nestedBody physics.
	outerWorld synchroniseMembership.
	nestedWorld synchroniseMembership.
	self assert: (outerWorld includes: outerBody).
	self assert: (outerWorld includes: nestedWorldElement).
	self assert: (outerWorld includes: nestedBody) not.
	self assert: (nestedWorld includes: nestedBody).
	^ root
]

{ #category : 'examples - worlds' }
CFPhysicsExamples >> physicsWorldWithOneBody [
	<gtExample>
	| root body world |
	root := BlElement new.
	body := BlElement new.
	root addChild: body.
	world := root physics beWorld.
	body physics.
	world synchroniseMembership.
	self assert: (world includes: body).
	^ root
]


{ #category : 'examples - presentation' }
CFPhysicsExamples >> manuallyPresentedBodyPose [
	<gtExample>
	| space worldElement body world |
	space := BlSpace new.
	worldElement := BlElement new
		size: 600 @ 400;
		yourself.
	body := BlElement new
		size: 80 @ 50;
		background: Color blue;
		yourself.
	space root addChild: worldElement.
	worldElement addChild: body.
	world := worldElement physics beWorld.
	body physics.
	world synchroniseMembership.
	body physics translation: 240 @ 140 rotation: 0.35.
	self assert: body physics position equals: 240 @ 140.
	self assert: body physics rotation equals: 0.35.
	self assert: body physics presentation isAttached.
	^ space
]


{ #category : 'examples - stepping' }
CFPhysicsExamples >> manuallySteppedFallingBody [
	<gtExample>
	| space worldElement body world |
	space := BlSpace new.
	worldElement := BlElement new
		size: 600 @ 400;
		yourself.
	body := BlElement new
		size: 50 @ 50;
		background: Color blue;
		yourself.
	space root addChild: worldElement.
	worldElement addChild: body.
	world := worldElement physics beWorld.
	body physics.
	world gravity: 0 @ 600.
	world step: 30.
	self assert: body physics isDynamic.
	self assert: body physics position y > 0.
	self assert: body physics velocity y > 0.
	^ space
]

{ #category : 'examples - collision' }
CFPhysicsExamples >> rectangleSettlesOnStaticGround [
	<gtExample>
	| space worldElement body ground world |
	space := BlSpace new.
	worldElement := BlElement new
		size: 600 @ 400;
		yourself.
	body := BlElement new
		size: 50 @ 50;
		background: Color blue;
		yourself.
	ground := BlElement new
		size: 400 @ 40;
		background: Color gray;
		yourself.
	space root addChild: worldElement.
	worldElement addChild: body.
	worldElement addChild: ground.
	world := worldElement physics beWorld.
	body physics position: 100 @ 0.
	ground physics
		beStatic;
		position: 0 @ 200.
	world
		stepDuration: 10 milliseconds;
		gravity: 0 @ 600;
		step: 120.
	self assert: (body physics position distanceTo: 100 @ 150) < 0.000001.
	self assert: (body physics velocity distanceTo: 0 @ 0) < 0.000001.
	self assert: world contacts size equals: 1.
	^ space
]

{ #category : 'examples - contacts' }
CFPhysicsExamples >> inspectPersistentContact [
	<gtExample>
	| owner body ground world contact |
	owner := BlElement new.
	body := BlElement new
		size: 50 @ 50;
		background: Color blue;
		yourself.
	ground := BlElement new
		size: 400 @ 40;
		background: Color gray;
		yourself.
	owner addChild: body.
	owner addChild: ground.
	world := owner physics beWorld.
	body physics position: 100 @ 0.
	ground physics beStatic; position: 0 @ 200.
	world stepDuration: 10 milliseconds; gravity: 0 @ 600; step: 120.
	contact := world contacts first.
	world step.
	self assert: world contacts first == contact.
	^ contact
]

{ #category : 'examples - collision' }
CFPhysicsExamples >> circleSettlesOnStaticGround [
	<gtExample>
	| space worldElement ball ground world |
	space := BlSpace new.
	worldElement := BlElement new
		size: 600 @ 400;
		yourself.
	ball := BlElement new
		geometry: BlCircleGeometry new;
		size: 50 @ 50;
		background: Color blue;
		yourself.
	ground := BlElement new
		size: 400 @ 40;
		background: Color gray;
		yourself.
	space root addChild: worldElement.
	worldElement addChild: ball.
	worldElement addChild: ground.
	world := worldElement physics beWorld.
	ball physics position: 100 @ 0.
	ground physics
		beStatic;
		position: 0 @ 200.
	world
		stepDuration: 10 milliseconds;
		gravity: 0 @ 600;
		step: 120.
	self assert: (ball physics position distanceTo: 100 @ 150) < 0.000001.
	self assert: (ball physics velocity distanceTo: 0 @ 0) < 0.000001.
	self assert: world contacts size equals: 1.
	self assert: world contacts first manifold points size equals: 1.
	^ space
]

{ #category : 'examples - materials' }
CFPhysicsExamples >> bouncingCircle [
	<gtExample>
	| space worldElement ball ground world |
	space := BlSpace new.
	worldElement := BlElement new size: 600 @ 400; yourself.
	ball := BlElement new geometry: BlCircleGeometry new; size: 50 @ 50; background: Color blue; yourself.
	ground := BlElement new size: 400 @ 40; background: Color gray; yourself.
	space root addChild: worldElement.
	worldElement addChild: ball.
	worldElement addChild: ground.
	world := worldElement physics beWorld.
	ball physics position: 100 @ 149; velocity: 0 @ 200; restitution: 0.8.
	ground physics beStatic; position: 0 @ 200; restitution: 0.8.
	world stepDuration: 10 milliseconds; gravity: 0 @ 600; step.
	self assert: ball physics velocity y < 0.
	^ space
]

{ #category : 'examples - materials' }
CFPhysicsExamples >> slidingRectangleWithFriction [
	<gtExample>
	| space worldElement body ground world initialSpeed |
	space := BlSpace new.
	worldElement := BlElement new size: 600 @ 400; yourself.
	body := BlElement new size: 50 @ 50; background: Color blue; yourself.
	ground := BlElement new size: 400 @ 40; background: Color gray; yourself.
	space root addChild: worldElement.
	worldElement addChild: body.
	worldElement addChild: ground.
	world := worldElement physics beWorld.
	body physics position: 100 @ 150; velocity: 200 @ 0; friction: 0.8.
	ground physics beStatic; position: 0 @ 200; friction: 0.8.
	initialSpeed := body physics velocity x.
	world stepDuration: 10 milliseconds; gravity: 0 @ 600; step: 10.
	self assert: body physics velocity x abs < initialSpeed abs.
	^ space
]

{ #category : 'examples - polygons' }
CFPhysicsExamples >> fallingConvexPolygon [
	<gtExample>
	| space worldElement polygon ground world |
	space := BlSpace new.
	worldElement := BlElement new size: 600 @ 400; yourself.
	polygon := BlElement new
		geometry: (BlPolygonGeometry vertices: { 0 @ 25. 25 @ 0. 50 @ 25. 25 @ 50 });
		size: 50 @ 50;
		background: Color blue;
		yourself.
	ground := BlElement new size: 400 @ 40; background: Color gray; yourself.
	space root addChild: worldElement.
	worldElement addChild: polygon.
	worldElement addChild: ground.
	world := worldElement physics beWorld.
	polygon physics position: 100 @ 0.
	ground physics beStatic; position: 0 @ 200.
	world stepDuration: 10 milliseconds; gravity: 0 @ 600; step: 120.
	self assert: world contacts notEmpty.
	^ space
]


{ #category : 'examples - convex collision' }
CFPhysicsExamples >> roundedRectangleSettlesOnRoundedGround [
	<gtExample>
	| space worldElement body ground world |
	space := BlSpace new.
	worldElement := BlElement new size: 600 @ 400; yourself.
	body := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 12);
		size: 50 @ 50;
		background: Color blue;
		yourself.
	ground := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		size: 400 @ 40;
		background: Color gray;
		yourself.
	space root addChild: worldElement.
	worldElement addChild: body.
	worldElement addChild: ground.
	world := worldElement physics beWorld.
	body physics position: 100 @ 0.
	ground physics beStatic; position: 0 @ 200.
	world stepDuration: 10 milliseconds; gravity: 0 @ 600; step: 120.
	self assert: body physics position y <= 150.0001.
	self assert: world contacts size equals: 1.
	^ space
]

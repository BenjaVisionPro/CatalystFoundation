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

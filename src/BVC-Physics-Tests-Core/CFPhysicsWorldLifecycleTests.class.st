Class {
	#name : 'CFPhysicsWorldLifecycleTests',
	#superclass : 'TestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - worlds' }
CFPhysicsWorldLifecycleTests >> testCeaseBeingWorldReleasesItsBodiesAndConstraints [
	<gtExample>
	| root first second world spring repulsion |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	world owner physics makeChildrenDynamic.
	spring := first physics distanceJointTo: second.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	repulsion := first physics repel: second.
	root physics ceaseBeingWorld.
	self assert: root physics world isNil.
	self assert: world members isEmpty.
	self assert: world springs isEmpty.
	self assert: world repulsions isEmpty.
	self deny: spring isActive.
	self deny: repulsion isActive
]


{ #category : 'tests - worlds' }
CFPhysicsWorldLifecycleTests >> testReleaseIsIdempotentAndMarksTheWorldReleased [
	<gtExample>
	| root world |
	root := BlElement new.
	world := root physics beWorld.
	self deny: world isReleased.
	world release.
	self assert: world isReleased.
	world release.
	self assert: world isReleased
]

{ #category : 'tests - worlds' }
CFPhysicsWorldLifecycleTests >> testReleasedWorldRejectsManualStepping [
	<gtExample>
	| root world |
	root := BlElement new.
	world := root physics beWorld.
	root physics ceaseBeingWorld.
	self assert: world isReleased.
	self
		should: [ world step ]
		raise: Error
		description: 'A released Physics world must reject further simulation'
]

{ #category : 'tests - configuration' }
CFPhysicsWorldLifecycleTests >> testStepDurationMustBePositive [
	<gtExample>
	| world |
	world := CFPhysicsWorld on: BlElement new.
	self
		should: [ world stepDuration: 0 milliseconds ]
		raise: Error.
	self
		should: [ world stepDuration: -1 milliseconds ]
		raise: Error
]

{ #category : 'tests - configuration' }
CFPhysicsWorldLifecycleTests >> testSubstepCountMustBeAPositiveInteger [
	<gtExample>
	| world |
	world := CFPhysicsWorld on: BlElement new.
	self should: [ world substepCount: 0 ] raise: Error.
	self should: [ world substepCount: -1 ] raise: Error.
	self should: [ world substepCount: 1.5 ] raise: Error.
	world substepCount: 1.
	self assert: world substepCount equals: 1
]

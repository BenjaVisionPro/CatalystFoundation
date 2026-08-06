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
	world synchroniseMembership.
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

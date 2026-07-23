Class {
	#name : 'CFPhysicsWindBehaviourTests',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests-Behaviours',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'tests - behaviours' }
CFPhysicsWindBehaviourTests >> testWindIsImmediatelyOwnedAndParticipating [
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new extent: 20 @ 20.
	root addChild: element.
	world := root physics beWorld.
	behaviour := element physics wind.
	self assert: element physics behaviours equals: { behaviour }.
	self assert: world behaviours equals: { behaviour }.
	self assert: behaviour physics identicalTo: element physics.
	self assert: behaviour world identicalTo: world
]

{ #category : 'tests - behaviours' }
CFPhysicsWindBehaviourTests >> testWindAppliesMotionDrivenDirectionalForce [
	| root element world behaviour body |
	root := BlElement new.
	element := BlElement new extent: 20 @ 20.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := element physics wind.
	behaviour direction: 1 @ 0; intensity: 0.5.
	world step.
	body := element physics requireBodyState.
	self assert: body velocity x > 0.0.
	self assert: (body velocity y closeTo: 0.0).
	self assert: behaviour currentForce x > 0.0
]

{ #category : 'tests - behaviours' }
CFPhysicsWindBehaviourTests >> testWindCanCoordinateASelectedCollection [
	| root first second third world behaviour |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	third := BlElement new extent: 20 @ 20.
	root addChildren: { first. second. third }.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := root physics windAffecting: { first. second }.
	behaviour direction: 0 @ 1; intensity: 0.5.
	world step.
	self assert: first physics requireBodyState velocity y > 0.0.
	self assert: second physics requireBodyState velocity y > 0.0.
	self assert: third physics requireBodyState velocity equals: 0 @ 0
]

{ #category : 'tests - behaviours' }
CFPhysicsWindBehaviourTests >> testWindIntensityRebuildsItsMotionProfile [
	| root element world behaviour lowForce highForce |
	root := BlElement new.
	element := BlElement new extent: 20 @ 20.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := element physics wind.
	behaviour intensity: 0.0.
	lowForce := behaviour currentForce x.
	behaviour intensity: 1.0.
	highForce := behaviour currentForce x.
	self assert: highForce > lowForce
]

{ #category : 'tests - behaviours' }
CFPhysicsWindBehaviourTests >> testRemovingWindPreventsFutureForce [
	| root element world behaviour body velocityAfterFirstStep |
	root := BlElement new.
	element := BlElement new extent: 20 @ 20.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := element physics wind.
	world step.
	body := element physics requireBodyState.
	velocityAfterFirstStep := body velocity.
	self assert: velocityAfterFirstStep x > 0.0.
	behaviour remove.
	body velocity: 0 @ 0.
	world step.
	self assert: body velocity equals: 0 @ 0
]

{ #category : 'tests - behaviours' }
CFPhysicsWindBehaviourTests >> testWindParticipantProviderCanChangeBetweenSteps [
	| root first second world selected behaviour |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	selected := { first }.
	behaviour := root physics windAffecting: [ selected ].
	world step.
	self assert: first physics requireBodyState velocity x > 0.0.
	self assert: second physics requireBodyState velocity equals: 0 @ 0.
	first physics requireBodyState velocity: 0 @ 0.
	selected := { second }.
	world step.
	self assert: first physics requireBodyState velocity equals: 0 @ 0.
	self assert: second physics requireBodyState velocity x > 0.0
]

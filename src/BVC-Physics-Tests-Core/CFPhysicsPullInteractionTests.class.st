Class {
	#name : 'CFPhysicsPullInteractionTests',
	#superclass : 'TestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - pull interaction' }
CFPhysicsPullInteractionTests >> testPullInteractionCanEndAfterItsWorldIsReleased [
	<gtExample>
	| root child world body handler constraint |
	root := BlElement new.
	child := BlElement new extent: 20 @ 20.
	root addChild: child.
	world := root physics beWorld.
	world synchroniseMembership.
	body := child physics body.
	handler := child physics pointerJointHandler.
	constraint := CFPhysicsMouseJoint body: body target: 10 @ 10.
	world addMouseJoint: constraint.
	handler instVarNamed: 'mouseJoint' put: constraint.
	root physics ceaseBeingWorld.
	self assert: body world isNil.
	self deny: constraint isActive.
	handler endFrom: nil.
	self assert: handler mouseJoint isNil
]


{ #category : 'tests - pull interaction' }
CFPhysicsPullInteractionTests >> testPullInteractionPreservesBodyVelocityWhenReleased [
	<gtExample>
	| root child world body handler joint |
	root := BlElement new.
	child := BlElement new extent: 20 @ 20.
	root addChild: child.
	world := root physics beWorld.
	world synchroniseMembership.
	body := child physics body.
	body
		velocity: 800 @ -200;
		angularVelocity: 3.5.
	handler := child physics pointerJointHandler.
	joint := CFPhysicsMouseJoint body: body target: 10 @ 10.
	world addMouseJoint: joint.
	handler instVarNamed: 'mouseJoint' put: joint.
	handler finishMouseJoint.
	self assert: body velocity equals: 800 @ -200.
	self assert: body angularVelocity equals: 3.5.
	self assert: world mouseJoints isEmpty
]

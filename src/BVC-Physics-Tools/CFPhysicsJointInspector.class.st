"I present the live diagnostic state shared by Physics joints and allow each joint type to add its own compact fields."
Class {
	#name : 'CFPhysicsJointInspector',
	#superclass : 'CFPhysicsOverlayInspector',
	#instVars : [ 'joint' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'accessing' }
CFPhysicsJointInspector >> joint [ ^ joint ]

{ #category : 'initialization' }
CFPhysicsJointInspector >> configureInspector [
	self addTitle: 'JOINT'.
	self addGroup: 'State' fields: {
		#jointType -> 'Type'.
		#active -> 'Active'.
		#sequence -> 'Sequence'.
		#collideConnected -> 'Collide connected' }.
	self addGroup: 'Connection' fields: {
		#bodyA -> 'First body'.
		#bodyB -> 'Second body' } columns: 1.
	self addGroup: 'Anchors' fields: {
		#anchorA -> 'First anchor'.
		#anchorB -> 'Second anchor' }
]

{ #category : 'inspecting' }
CFPhysicsJointInspector >> inspect: aJoint [
	joint := aJoint.
	joint addPhysicsOverlayInspectorGroupsTo: self.
	self refresh.
	^ self
]

{ #category : 'clearing' }
CFPhysicsJointInspector >> clear [
	joint := nil.
	self clearValues.
	^ self
]

{ #category : 'private - formatting' }
CFPhysicsJointInspector >> jointTypeName [
	| name |
	name := joint class name.
	(name beginsWith: 'CFPhysics') ifTrue: [ name := name allButFirst: 9 ].
	(name endsWith: 'Joint') ifTrue: [ name := name allButLast: 5 ].
	^ name
]

{ #category : 'updating' }
CFPhysicsJointInspector >> refresh [
	| points |
	joint ifNil: [ ^ self ].
	points := joint physicsOverlayWorldPoints.
	self text: self jointTypeName at: #jointType.
	self text: joint isActive printString at: #active.
	self text: joint sequence printString at: #sequence.
	self text: joint collideConnected printString at: #collideConnected.
	self text: (self labelForBody: joint bodyA) at: #bodyA.
	self text: (self labelForBody: joint bodyB) at: #bodyB.
	self diagnosticPoint: points first at: #anchorA.
	self diagnosticPoint: points second at: #anchorB.
	joint refreshPhysicsOverlayInspector: self.
	^ self
]

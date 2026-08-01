"
I represent a contact constraint prepared for one solver step. I bind a contact to its body states, contact frame, material response and prepared points.
"

Class {
	#name : 'CFPhysicsPreparedConstraint',
	#superclass : 'Object',
	#instVars : [ 'contact', 'bodyStateA', 'bodyStateB', 'normal', 'tangent', 'friction', 'restitution', 'rollingResistance', 'rollingMass', 'rollingImpulse', 'tangentSpeed', 'points' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'writing back' }
CFPhysicsPreparedConstraint >> writeImpulsesBack [
	points do: [ :point | point writeImpulsesBack ].
	contact manifold rollingImpulse: rollingImpulse
]

{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> contact [ ^ contact ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> contact: anObject [ contact := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> bodyA [ ^ contact firstBody ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> bodyB [ ^ contact secondBody ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> bodyStateA [ ^ bodyStateA ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> bodyStateA: anObject [ bodyStateA := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> bodyStateB [ ^ bodyStateB ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> bodyStateB: anObject [ bodyStateB := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> normal [ ^ normal ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> normal: aPoint [ normal := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> tangent [ ^ tangent ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> tangent: aPoint [ tangent := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> friction [ ^ friction ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> friction: aNumber [ friction := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> restitution [ ^ restitution ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> restitution: aNumber [ restitution := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> tangentSpeed [ ^ tangentSpeed ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> tangentSpeed: aNumber [ tangentSpeed := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> points [ ^ points ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> points: aCollection [ points := aCollection ]


{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> rollingResistance [ ^ rollingResistance ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> rollingResistance: aNumber [ rollingResistance := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> rollingMass [ ^ rollingMass ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> rollingMass: aNumber [ rollingMass := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> rollingImpulse [ ^ rollingImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> rollingImpulse: aNumber [ rollingImpulse := aNumber ]

"
I represent the common step-local state of a prepared joint constraint. I bind a persistent joint to the two body states solved during the step.
"

Class {
	#name : 'CFPhysicsPreparedJointConstraint',
	#superclass : 'Object',
	#instVars : [ 'joint', 'bodyStateA', 'bodyStateB' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsPreparedJointConstraint >> joint [ ^ joint ]
{ #category : 'accessing' }
CFPhysicsPreparedJointConstraint >> joint: anObject [ joint := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedJointConstraint >> firstBody [ ^ joint firstBody ]
{ #category : 'accessing' }
CFPhysicsPreparedJointConstraint >> secondBody [ ^ joint secondBody ]
{ #category : 'accessing' }
CFPhysicsPreparedJointConstraint >> bodyStateA [ ^ bodyStateA ]
{ #category : 'accessing' }
CFPhysicsPreparedJointConstraint >> bodyStateA: anObject [ bodyStateA := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedJointConstraint >> bodyStateB [ ^ bodyStateB ]
{ #category : 'accessing' }
CFPhysicsPreparedJointConstraint >> bodyStateB: anObject [ bodyStateB := anObject ]

{ #category : 'writing back' }
CFPhysicsPreparedJointConstraint >> writeImpulsesBack [
	self subclassResponsibility
]

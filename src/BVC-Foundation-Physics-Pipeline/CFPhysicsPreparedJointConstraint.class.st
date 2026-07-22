Class {
	#name : 'CFPhysicsPreparedJointConstraint',
	#superclass : 'Object',
	#instVars : [ 'joint', 'bodyStateA', 'bodyStateB' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
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

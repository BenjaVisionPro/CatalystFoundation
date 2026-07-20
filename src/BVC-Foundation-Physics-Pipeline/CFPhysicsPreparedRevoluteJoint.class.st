Class {
	#name : 'CFPhysicsPreparedRevoluteJoint',
	#superclass : 'Object',
	#instVars : [ 'joint', 'bodyStateA', 'bodyStateB', 'anchorA', 'anchorB', 'baseSeparation', 'effectiveMassXX', 'effectiveMassXY', 'effectiveMassYY', 'impulse' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> joint [ ^ joint ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> joint: anObject [ joint := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> firstBody [ ^ joint firstBody ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> secondBody [ ^ joint secondBody ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> bodyStateA [ ^ bodyStateA ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> bodyStateA: anObject [ bodyStateA := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> bodyStateB [ ^ bodyStateB ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> bodyStateB: anObject [ bodyStateB := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> anchorA [ ^ anchorA ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> anchorA: aPoint [ anchorA := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> anchorB [ ^ anchorB ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> anchorB: aPoint [ anchorB := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> baseSeparation [ ^ baseSeparation ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> baseSeparation: aPoint [ baseSeparation := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> effectiveMassXX [ ^ effectiveMassXX ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> effectiveMassXX: aNumber [ effectiveMassXX := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> effectiveMassXY [ ^ effectiveMassXY ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> effectiveMassXY: aNumber [ effectiveMassXY := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> effectiveMassYY [ ^ effectiveMassYY ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> effectiveMassYY: aNumber [ effectiveMassYY := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> impulse [ ^ impulse ]
{ #category : 'accessing' }
CFPhysicsPreparedRevoluteJoint >> impulse: aPoint [ impulse := aPoint ]

{ #category : 'writing back' }
CFPhysicsPreparedRevoluteJoint >> writeImpulsesBack [
	joint accumulatedImpulse: impulse
]

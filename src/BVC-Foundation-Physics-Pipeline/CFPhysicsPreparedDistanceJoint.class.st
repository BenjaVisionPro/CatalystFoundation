Class {
	#name : 'CFPhysicsPreparedDistanceJoint',
	#superclass : 'Object',
	#instVars : [ 'joint', 'bodyStateA', 'bodyStateB', 'anchorA', 'anchorB', 'direction', 'baseSeparation', 'effectiveMass', 'impulse' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> joint [ ^ joint ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> joint: anObject [ joint := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> firstBody [ ^ joint firstBody ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> secondBody [ ^ joint secondBody ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> bodyStateA [ ^ bodyStateA ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> bodyStateA: anObject [ bodyStateA := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> bodyStateB [ ^ bodyStateB ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> bodyStateB: anObject [ bodyStateB := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> anchorA [ ^ anchorA ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> anchorA: aPoint [ anchorA := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> anchorB [ ^ anchorB ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> anchorB: aPoint [ anchorB := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> direction [ ^ direction ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> direction: aPoint [ direction := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> baseSeparation [ ^ baseSeparation ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> baseSeparation: aNumber [ baseSeparation := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> effectiveMass [ ^ effectiveMass ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> effectiveMass: aNumber [ effectiveMass := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> impulse [ ^ impulse ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> impulse: aNumber [ impulse := aNumber ]

{ #category : 'writing back' }
CFPhysicsPreparedDistanceJoint >> writeImpulsesBack [
	joint accumulatedImpulse: impulse
]

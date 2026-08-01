"I represent a Box2D 3.1.1 distance joint prepared for one solver step."
Class {
	#name : 'CFPhysicsPreparedDistanceJoint',
	#superclass : 'CFPhysicsPreparedJointConstraint',
	#instVars : [ 'anchorA', 'anchorB', 'direction', 'baseLength', 'effectiveMass', 'springEnabled', 'biasRate', 'massCoefficient', 'impulseCoefficient', 'impulse' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> anchorA [ ^ anchorA ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> anchorA: anObject [ anchorA := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> anchorB [ ^ anchorB ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> anchorB: anObject [ anchorB := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> direction [ ^ direction ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> direction: anObject [ direction := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> baseLength [ ^ baseLength ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> baseLength: anObject [ baseLength := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> effectiveMass [ ^ effectiveMass ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> effectiveMass: anObject [ effectiveMass := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> springEnabled [ ^ springEnabled ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> springEnabled: anObject [ springEnabled := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> biasRate [ ^ biasRate ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> biasRate: anObject [ biasRate := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> massCoefficient [ ^ massCoefficient ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> massCoefficient: anObject [ massCoefficient := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> impulseCoefficient [ ^ impulseCoefficient ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> impulseCoefficient: anObject [ impulseCoefficient := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> impulse [ ^ impulse ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> impulse: anObject [ impulse := anObject ]

{ #category : 'writing back' }
CFPhysicsPreparedDistanceJoint >> writeImpulsesBack [
	joint solverCommitTarget impulse: impulse
]

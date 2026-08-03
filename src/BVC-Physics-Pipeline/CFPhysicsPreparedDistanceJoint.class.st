"I represent a Box2D 3.1.1 distance joint prepared for one solver step."
Class {
	#name : 'CFPhysicsPreparedDistanceJoint',
	#superclass : 'CFPhysicsPreparedJointConstraint',
	#instVars : [ 'anchorA', 'anchorB', 'direction', 'baseLength', 'effectiveMass', 'springEnabled', 'biasRate', 'massCoefficient', 'impulseCoefficient', 'impulse', 'limitsEnabled', 'minimumLength', 'maximumLength', 'lowerLimitImpulse', 'upperLimitImpulse', 'motorEnabled', 'motorSpeed', 'maximumMotorImpulse', 'motorImpulse' ],
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

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> limitsEnabled [ ^ limitsEnabled ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> limitsEnabled: anObject [ limitsEnabled := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> minimumLength [ ^ minimumLength ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> minimumLength: anObject [ minimumLength := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> maximumLength [ ^ maximumLength ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> maximumLength: anObject [ maximumLength := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> lowerLimitImpulse [ ^ lowerLimitImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> lowerLimitImpulse: anObject [ lowerLimitImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> upperLimitImpulse [ ^ upperLimitImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> upperLimitImpulse: anObject [ upperLimitImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> motorEnabled [ ^ motorEnabled ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> motorEnabled: anObject [ motorEnabled := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> motorSpeed [ ^ motorSpeed ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> motorSpeed: anObject [ motorSpeed := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> maximumMotorImpulse [ ^ maximumMotorImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> maximumMotorImpulse: anObject [ maximumMotorImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> motorImpulse [ ^ motorImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedDistanceJoint >> motorImpulse: anObject [ motorImpulse := anObject ]

{ #category : 'writing back' }
CFPhysicsPreparedDistanceJoint >> writeImpulsesBack [
	joint solverCommitTarget
		impulse: impulse;
		lowerLimitImpulse: lowerLimitImpulse;
		upperLimitImpulse: upperLimitImpulse;
		motorImpulse: motorImpulse
]

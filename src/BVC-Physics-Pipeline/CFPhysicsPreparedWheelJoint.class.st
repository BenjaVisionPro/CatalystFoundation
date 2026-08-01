"I represent a Box2D 3.1.1 wheel joint prepared for one solver step."
Class {
	#name : 'CFPhysicsPreparedWheelJoint',
	#superclass : 'CFPhysicsPreparedJointConstraint',
	#instVars : [ 'anchorA', 'anchorB', 'axis', 'normal', 'basePerpendicularSeparation', 'perpendicularMass', 'perpendicularImpulse', 'baseTranslation', 'axialMass', 'springEnabled', 'springBiasRate', 'springMassCoefficient', 'springImpulseCoefficient', 'springImpulse', 'limitsEnabled', 'lowerTranslation', 'upperTranslation', 'lowerLimitImpulse', 'upperLimitImpulse', 'motorEnabled', 'motorSpeed', 'motorMass', 'maximumMotorImpulse', 'motorImpulse' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> anchorA [ ^ anchorA ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> anchorA: anObject [ anchorA := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> anchorB [ ^ anchorB ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> anchorB: anObject [ anchorB := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> axis [ ^ axis ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> axis: anObject [ axis := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> normal [ ^ normal ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> normal: anObject [ normal := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> basePerpendicularSeparation [ ^ basePerpendicularSeparation ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> basePerpendicularSeparation: anObject [ basePerpendicularSeparation := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> perpendicularMass [ ^ perpendicularMass ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> perpendicularMass: anObject [ perpendicularMass := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> perpendicularImpulse [ ^ perpendicularImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> perpendicularImpulse: anObject [ perpendicularImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> baseTranslation [ ^ baseTranslation ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> baseTranslation: anObject [ baseTranslation := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> axialMass [ ^ axialMass ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> axialMass: anObject [ axialMass := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> springEnabled [ ^ springEnabled ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> springEnabled: anObject [ springEnabled := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> springBiasRate [ ^ springBiasRate ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> springBiasRate: anObject [ springBiasRate := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> springMassCoefficient [ ^ springMassCoefficient ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> springMassCoefficient: anObject [ springMassCoefficient := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> springImpulseCoefficient [ ^ springImpulseCoefficient ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> springImpulseCoefficient: anObject [ springImpulseCoefficient := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> springImpulse [ ^ springImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> springImpulse: anObject [ springImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> limitsEnabled [ ^ limitsEnabled ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> limitsEnabled: anObject [ limitsEnabled := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> lowerTranslation [ ^ lowerTranslation ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> lowerTranslation: anObject [ lowerTranslation := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> upperTranslation [ ^ upperTranslation ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> upperTranslation: anObject [ upperTranslation := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> lowerLimitImpulse [ ^ lowerLimitImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> lowerLimitImpulse: anObject [ lowerLimitImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> upperLimitImpulse [ ^ upperLimitImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> upperLimitImpulse: anObject [ upperLimitImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> motorEnabled [ ^ motorEnabled ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> motorEnabled: anObject [ motorEnabled := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> motorSpeed [ ^ motorSpeed ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> motorSpeed: anObject [ motorSpeed := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> motorMass [ ^ motorMass ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> motorMass: anObject [ motorMass := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> maximumMotorImpulse [ ^ maximumMotorImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> maximumMotorImpulse: anObject [ maximumMotorImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> motorImpulse [ ^ motorImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedWheelJoint >> motorImpulse: anObject [ motorImpulse := anObject ]

{ #category : 'writing back' }
CFPhysicsPreparedWheelJoint >> writeImpulsesBack [
	joint solverCommitTarget
		perpendicularImpulse: perpendicularImpulse;
		springImpulse: springImpulse;
		lowerLimitImpulse: lowerLimitImpulse;
		upperLimitImpulse: upperLimitImpulse;
		motorImpulse: motorImpulse
]

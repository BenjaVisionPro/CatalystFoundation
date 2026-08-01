"I represent a Box2D 3.1.1 prismatic joint prepared for one solver step."
Class {
	#name : 'CFPhysicsPreparedPrismaticJoint',
	#superclass : 'CFPhysicsPreparedJointConstraint',
	#instVars : [ 'anchorA', 'anchorB', 'axis', 'normal', 'basePerpendicularSeparation', 'perpendicularMass', 'perpendicularImpulse', 'baseTranslation', 'axialMass', 'springEnabled', 'springBiasRate', 'springMassCoefficient', 'springImpulseCoefficient', 'springImpulse', 'limitsEnabled', 'lowerTranslation', 'upperTranslation', 'lowerLimitImpulse', 'upperLimitImpulse', 'motorEnabled', 'motorSpeed', 'maximumMotorImpulse', 'motorImpulse', 'baseAngle', 'angularMass', 'angularImpulse' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> anchorA [ ^ anchorA ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> anchorA: anObject [ anchorA := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> anchorB [ ^ anchorB ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> anchorB: anObject [ anchorB := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> axis [ ^ axis ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> axis: anObject [ axis := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> normal [ ^ normal ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> normal: anObject [ normal := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> basePerpendicularSeparation [ ^ basePerpendicularSeparation ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> basePerpendicularSeparation: anObject [ basePerpendicularSeparation := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> perpendicularMass [ ^ perpendicularMass ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> perpendicularMass: anObject [ perpendicularMass := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> perpendicularImpulse [ ^ perpendicularImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> perpendicularImpulse: anObject [ perpendicularImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> baseTranslation [ ^ baseTranslation ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> baseTranslation: anObject [ baseTranslation := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> axialMass [ ^ axialMass ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> axialMass: anObject [ axialMass := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> springEnabled [ ^ springEnabled ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> springEnabled: anObject [ springEnabled := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> springBiasRate [ ^ springBiasRate ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> springBiasRate: anObject [ springBiasRate := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> springMassCoefficient [ ^ springMassCoefficient ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> springMassCoefficient: anObject [ springMassCoefficient := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> springImpulseCoefficient [ ^ springImpulseCoefficient ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> springImpulseCoefficient: anObject [ springImpulseCoefficient := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> springImpulse [ ^ springImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> springImpulse: anObject [ springImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> limitsEnabled [ ^ limitsEnabled ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> limitsEnabled: anObject [ limitsEnabled := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> lowerTranslation [ ^ lowerTranslation ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> lowerTranslation: anObject [ lowerTranslation := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> upperTranslation [ ^ upperTranslation ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> upperTranslation: anObject [ upperTranslation := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> lowerLimitImpulse [ ^ lowerLimitImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> lowerLimitImpulse: anObject [ lowerLimitImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> upperLimitImpulse [ ^ upperLimitImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> upperLimitImpulse: anObject [ upperLimitImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> motorEnabled [ ^ motorEnabled ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> motorEnabled: anObject [ motorEnabled := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> motorSpeed [ ^ motorSpeed ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> motorSpeed: anObject [ motorSpeed := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> maximumMotorImpulse [ ^ maximumMotorImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> maximumMotorImpulse: anObject [ maximumMotorImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> motorImpulse [ ^ motorImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> motorImpulse: anObject [ motorImpulse := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> baseAngle [ ^ baseAngle ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> baseAngle: anObject [ baseAngle := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> angularMass [ ^ angularMass ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> angularMass: anObject [ angularMass := anObject ]

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> angularImpulse [ ^ angularImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> angularImpulse: anObject [ angularImpulse := anObject ]

{ #category : 'writing back' }
CFPhysicsPreparedPrismaticJoint >> writeImpulsesBack [
	joint solverCommitTarget
		perpendicularImpulse: perpendicularImpulse;
		angularImpulse: angularImpulse;
		springImpulse: springImpulse;
		lowerLimitImpulse: lowerLimitImpulse;
		upperLimitImpulse: upperLimitImpulse;
		motorImpulse: motorImpulse
]

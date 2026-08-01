"
I represent a revolute joint prepared for one solver step. I hold its pivot constraint together with optional limits and motor state.
"

Class {
	#name : 'CFPhysicsPreparedRevoluteJoint',
	#superclass : 'CFPhysicsPreparedJointConstraint',
	#instVars : [ 'anchorA', 'anchorB', 'baseSeparation', 'effectiveMassXX', 'effectiveMassXY', 'effectiveMassYY', 'impulse', 'limitBaseAngle', 'limitsEnabled', 'lowerAngle', 'upperAngle', 'limitMass', 'lowerLimitImpulse', 'upperLimitImpulse', 'motorEnabled', 'motorSpeed', 'maximumMotorImpulse', 'motorMass', 'motorImpulse', 'springEnabled', 'springBaseAngle', 'targetAngle', 'springBiasRate', 'springMassCoefficient', 'springImpulseCoefficient', 'springImpulse' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

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

{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> springEnabled [ ^ springEnabled ]
{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> springEnabled: aBoolean [ springEnabled := aBoolean ]
{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> springBaseAngle [ ^ springBaseAngle ]
{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> springBaseAngle: aNumber [ springBaseAngle := aNumber ]
{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> targetAngle [ ^ targetAngle ]
{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> targetAngle: aNumber [ targetAngle := aNumber ]
{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> springBiasRate [ ^ springBiasRate ]
{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> springBiasRate: aNumber [ springBiasRate := aNumber ]
{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> springMassCoefficient [ ^ springMassCoefficient ]
{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> springMassCoefficient: aNumber [ springMassCoefficient := aNumber ]
{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> springImpulseCoefficient [ ^ springImpulseCoefficient ]
{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> springImpulseCoefficient: aNumber [ springImpulseCoefficient := aNumber ]
{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> springImpulse [ ^ springImpulse ]
{ #category : 'spring' }
CFPhysicsPreparedRevoluteJoint >> springImpulse: aNumber [ springImpulse := aNumber ]

{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> limitBaseAngle [ ^ limitBaseAngle ]

{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> limitBaseAngle: aNumber [ limitBaseAngle := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> limitsEnabled [ ^ limitsEnabled ]
{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> limitsEnabled: aBoolean [ limitsEnabled := aBoolean ]
{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> lowerAngle [ ^ lowerAngle ]
{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> lowerAngle: aNumber [ lowerAngle := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> upperAngle [ ^ upperAngle ]
{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> upperAngle: aNumber [ upperAngle := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> limitMass [ ^ limitMass ]
{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> limitMass: aNumber [ limitMass := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> lowerLimitImpulse [ ^ lowerLimitImpulse ]
{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> lowerLimitImpulse: aNumber [ lowerLimitImpulse := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> upperLimitImpulse [ ^ upperLimitImpulse ]
{ #category : 'limits' }
CFPhysicsPreparedRevoluteJoint >> upperLimitImpulse: aNumber [ upperLimitImpulse := aNumber ]
{ #category : 'motor' }
CFPhysicsPreparedRevoluteJoint >> motorEnabled [ ^ motorEnabled ]
{ #category : 'motor' }
CFPhysicsPreparedRevoluteJoint >> motorEnabled: aBoolean [ motorEnabled := aBoolean ]
{ #category : 'motor' }
CFPhysicsPreparedRevoluteJoint >> motorSpeed [ ^ motorSpeed ]
{ #category : 'motor' }
CFPhysicsPreparedRevoluteJoint >> motorSpeed: aNumber [ motorSpeed := aNumber ]
{ #category : 'motor' }
CFPhysicsPreparedRevoluteJoint >> maximumMotorImpulse [ ^ maximumMotorImpulse ]
{ #category : 'motor' }
CFPhysicsPreparedRevoluteJoint >> maximumMotorImpulse: aNumber [ maximumMotorImpulse := aNumber ]
{ #category : 'motor' }
CFPhysicsPreparedRevoluteJoint >> motorMass [ ^ motorMass ]
{ #category : 'motor' }
CFPhysicsPreparedRevoluteJoint >> motorMass: aNumber [ motorMass := aNumber ]
{ #category : 'motor' }
CFPhysicsPreparedRevoluteJoint >> motorImpulse [ ^ motorImpulse ]
{ #category : 'motor' }
CFPhysicsPreparedRevoluteJoint >> motorImpulse: aNumber [ motorImpulse := aNumber ]

{ #category : 'writing back' }
CFPhysicsPreparedRevoluteJoint >> writeImpulsesBack [
	joint solverCommitTarget
		accumulatedImpulse: impulse;
		springImpulse: springImpulse;
		lowerLimitImpulse: lowerLimitImpulse;
		upperLimitImpulse: upperLimitImpulse;
		motorImpulse: motorImpulse
]

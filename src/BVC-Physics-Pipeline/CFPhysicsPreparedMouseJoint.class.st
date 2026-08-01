"
I represent a mouse joint prepared for one solver step.
"
Class {
	#name : 'CFPhysicsPreparedMouseJoint',
	#superclass : 'CFPhysicsPreparedJointConstraint',
	#instVars : [ 'anchorB', 'baseSeparation', 'effectiveMassXX', 'effectiveMassXY', 'effectiveMassYY', 'biasRate', 'massCoefficient', 'impulseCoefficient', 'angularMass', 'angularMassCoefficient', 'angularImpulseCoefficient', 'maximumImpulse', 'linearImpulse', 'angularImpulse' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsPreparedMouseJoint >> anchorB [ ^ anchorB ]
{ #category : 'accessing' }
CFPhysicsPreparedMouseJoint >> anchorB: aPoint [ anchorB := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedMouseJoint >> baseSeparation [ ^ baseSeparation ]
{ #category : 'accessing' }
CFPhysicsPreparedMouseJoint >> baseSeparation: aPoint [ baseSeparation := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedMouseJoint >> effectiveMassXX [ ^ effectiveMassXX ]
{ #category : 'accessing' }
CFPhysicsPreparedMouseJoint >> effectiveMassXX: aNumber [ effectiveMassXX := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedMouseJoint >> effectiveMassXY [ ^ effectiveMassXY ]
{ #category : 'accessing' }
CFPhysicsPreparedMouseJoint >> effectiveMassXY: aNumber [ effectiveMassXY := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedMouseJoint >> effectiveMassYY [ ^ effectiveMassYY ]
{ #category : 'accessing' }
CFPhysicsPreparedMouseJoint >> effectiveMassYY: aNumber [ effectiveMassYY := aNumber ]
{ #category : 'softness' }
CFPhysicsPreparedMouseJoint >> biasRate [ ^ biasRate ]
{ #category : 'softness' }
CFPhysicsPreparedMouseJoint >> biasRate: aNumber [ biasRate := aNumber ]
{ #category : 'softness' }
CFPhysicsPreparedMouseJoint >> massCoefficient [ ^ massCoefficient ]
{ #category : 'softness' }
CFPhysicsPreparedMouseJoint >> massCoefficient: aNumber [ massCoefficient := aNumber ]
{ #category : 'softness' }
CFPhysicsPreparedMouseJoint >> impulseCoefficient [ ^ impulseCoefficient ]
{ #category : 'softness' }
CFPhysicsPreparedMouseJoint >> impulseCoefficient: aNumber [ impulseCoefficient := aNumber ]
{ #category : 'softness' }
CFPhysicsPreparedMouseJoint >> angularMass [ ^ angularMass ]
{ #category : 'softness' }
CFPhysicsPreparedMouseJoint >> angularMass: aNumber [ angularMass := aNumber ]
{ #category : 'softness' }
CFPhysicsPreparedMouseJoint >> angularMassCoefficient [ ^ angularMassCoefficient ]
{ #category : 'softness' }
CFPhysicsPreparedMouseJoint >> angularMassCoefficient: aNumber [ angularMassCoefficient := aNumber ]
{ #category : 'softness' }
CFPhysicsPreparedMouseJoint >> angularImpulseCoefficient [ ^ angularImpulseCoefficient ]
{ #category : 'softness' }
CFPhysicsPreparedMouseJoint >> angularImpulseCoefficient: aNumber [ angularImpulseCoefficient := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedMouseJoint >> maximumImpulse [ ^ maximumImpulse ]
{ #category : 'limits' }
CFPhysicsPreparedMouseJoint >> maximumImpulse: aNumber [ maximumImpulse := aNumber ]
{ #category : 'solver state' }
CFPhysicsPreparedMouseJoint >> linearImpulse [ ^ linearImpulse ]
{ #category : 'solver state' }
CFPhysicsPreparedMouseJoint >> linearImpulse: aPoint [ linearImpulse := aPoint ]
{ #category : 'solver state' }
CFPhysicsPreparedMouseJoint >> angularImpulse [ ^ angularImpulse ]
{ #category : 'solver state' }
CFPhysicsPreparedMouseJoint >> angularImpulse: aNumber [ angularImpulse := aNumber ]
{ #category : 'writing back' }
CFPhysicsPreparedMouseJoint >> writeImpulsesBack [
	joint solverCommitTarget
		linearImpulse: linearImpulse;
		angularImpulse: angularImpulse
]

"I represent a Box2D 3.1.1 motor joint prepared for one solver step."
Class {
	#name : 'CFPhysicsPreparedMotorJoint',
	#superclass : 'CFPhysicsPreparedJointConstraint',
	#instVars : [ 'anchorA', 'anchorB', 'baseLinearSeparation', 'baseAngularSeparation', 'effectiveMassXX', 'effectiveMassXY', 'effectiveMassYY', 'angularMass', 'maximumLinearImpulse', 'maximumAngularImpulse', 'linearImpulse', 'angularImpulse' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> anchorA [ ^ anchorA ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> anchorA: aPoint [ anchorA := aPoint ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> anchorB [ ^ anchorB ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> anchorB: aPoint [ anchorB := aPoint ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> baseLinearSeparation [ ^ baseLinearSeparation ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> baseLinearSeparation: aPoint [ baseLinearSeparation := aPoint ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> baseAngularSeparation [ ^ baseAngularSeparation ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> baseAngularSeparation: aNumber [ baseAngularSeparation := aNumber ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> effectiveMassXX [ ^ effectiveMassXX ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> effectiveMassXX: aNumber [ effectiveMassXX := aNumber ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> effectiveMassXY [ ^ effectiveMassXY ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> effectiveMassXY: aNumber [ effectiveMassXY := aNumber ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> effectiveMassYY [ ^ effectiveMassYY ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> effectiveMassYY: aNumber [ effectiveMassYY := aNumber ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> angularMass [ ^ angularMass ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> angularMass: aNumber [ angularMass := aNumber ]
{ #category : 'limits' } CFPhysicsPreparedMotorJoint >> maximumLinearImpulse [ ^ maximumLinearImpulse ]
{ #category : 'limits' } CFPhysicsPreparedMotorJoint >> maximumLinearImpulse: aNumber [ maximumLinearImpulse := aNumber ]
{ #category : 'limits' } CFPhysicsPreparedMotorJoint >> maximumAngularImpulse [ ^ maximumAngularImpulse ]
{ #category : 'limits' } CFPhysicsPreparedMotorJoint >> maximumAngularImpulse: aNumber [ maximumAngularImpulse := aNumber ]
{ #category : 'solver state' } CFPhysicsPreparedMotorJoint >> linearImpulse [ ^ linearImpulse ]
{ #category : 'solver state' } CFPhysicsPreparedMotorJoint >> linearImpulse: aPoint [ linearImpulse := aPoint ]
{ #category : 'solver state' } CFPhysicsPreparedMotorJoint >> angularImpulse [ ^ angularImpulse ]
{ #category : 'solver state' } CFPhysicsPreparedMotorJoint >> angularImpulse: aNumber [ angularImpulse := aNumber ]
{ #category : 'writing back' }
CFPhysicsPreparedMotorJoint >> writeImpulsesBack [
	joint solverCommitTarget
		linearImpulse: linearImpulse;
		angularImpulse: angularImpulse
]

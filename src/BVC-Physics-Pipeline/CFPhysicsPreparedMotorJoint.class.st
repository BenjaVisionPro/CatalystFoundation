"I represent a motor joint prepared for one solver step."
Class {
	#name : 'CFPhysicsPreparedMotorJoint',
	#superclass : 'CFPhysicsPreparedJointConstraint',
	#instVars : [ 'baseLinearSeparation', 'baseAngularSeparation', 'linearMass', 'angularMass', 'maximumLinearImpulse', 'maximumAngularImpulse', 'linearImpulse', 'angularImpulse' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> baseLinearSeparation [ ^ baseLinearSeparation ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> baseLinearSeparation: aPoint [ baseLinearSeparation := aPoint ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> baseAngularSeparation [ ^ baseAngularSeparation ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> baseAngularSeparation: aNumber [ baseAngularSeparation := aNumber ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> linearMass [ ^ linearMass ]
{ #category : 'accessing' } CFPhysicsPreparedMotorJoint >> linearMass: aNumber [ linearMass := aNumber ]
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
CFPhysicsPreparedMotorJoint >> writeImpulsesBack [ joint solverCommitTarget linearImpulse: linearImpulse; angularImpulse: angularImpulse ]

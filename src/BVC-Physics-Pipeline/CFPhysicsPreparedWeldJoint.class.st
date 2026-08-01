"
I represent a weld joint prepared for one solver step. I extend the shared joint constraint with angular preservation state.
"

Class {
	#name : 'CFPhysicsPreparedWeldJoint',
	#superclass : 'CFPhysicsPreparedRevoluteJoint',
	#instVars : [ 'baseAngle', 'angularMass', 'angularImpulse' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> baseAngle [ ^ baseAngle ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> baseAngle: aNumber [ baseAngle := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> angularMass [ ^ angularMass ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> angularMass: aNumber [ angularMass := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> angularImpulse [ ^ angularImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> angularImpulse: aNumber [ angularImpulse := aNumber ]

{ #category : 'writing back' }
CFPhysicsPreparedWeldJoint >> writeImpulsesBack [
	joint solverCommitTarget
		accumulatedImpulse: impulse;
		accumulatedAngularImpulse: angularImpulse
]

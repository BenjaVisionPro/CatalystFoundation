"
I represent a fixed joint prepared for one solver step. I extend the shared joint constraint with angular preservation state.
"

Class {
	#name : 'CFPhysicsPreparedFixedJoint',
	#superclass : 'CFPhysicsPreparedRevoluteJoint',
	#instVars : [ 'baseAngle', 'angularMass', 'angularImpulse' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsPreparedFixedJoint >> baseAngle [ ^ baseAngle ]
{ #category : 'accessing' }
CFPhysicsPreparedFixedJoint >> baseAngle: aNumber [ baseAngle := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedFixedJoint >> angularMass [ ^ angularMass ]
{ #category : 'accessing' }
CFPhysicsPreparedFixedJoint >> angularMass: aNumber [ angularMass := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedFixedJoint >> angularImpulse [ ^ angularImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedFixedJoint >> angularImpulse: aNumber [ angularImpulse := aNumber ]

{ #category : 'writing back' }
CFPhysicsPreparedFixedJoint >> writeImpulsesBack [
	joint solverCommitTarget
		accumulatedImpulse: impulse;
		accumulatedAngularImpulse: angularImpulse
]

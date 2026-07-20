Class {
	#name : 'CFPhysicsPreparedFixedJoint',
	#superclass : 'CFPhysicsPreparedRevoluteJoint',
	#instVars : [ 'baseAngle', 'angularMass', 'angularImpulse' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
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
	super writeImpulsesBack.
	joint accumulatedAngularImpulse: angularImpulse
]

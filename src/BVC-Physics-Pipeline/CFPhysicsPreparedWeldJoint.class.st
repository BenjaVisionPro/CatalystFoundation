"
I represent a weld joint prepared for one solver step. I extend the shared joint constraint with angular preservation state.
"

Class {
	#name : 'CFPhysicsPreparedWeldJoint',
	#superclass : 'CFPhysicsPreparedRevoluteJoint',
	#instVars : [ 'baseAngle', 'angularMass', 'angularImpulse', 'linearSoftnessEnabled', 'linearBiasRate', 'linearMassCoefficient', 'linearImpulseCoefficient', 'angularSoftnessEnabled', 'angularBiasRate', 'angularMassCoefficient', 'angularImpulseCoefficient' ],
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


{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> linearSoftnessEnabled [ ^ linearSoftnessEnabled ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> linearSoftnessEnabled: aBoolean [ linearSoftnessEnabled := aBoolean ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> linearBiasRate [ ^ linearBiasRate ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> linearBiasRate: aNumber [ linearBiasRate := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> linearMassCoefficient [ ^ linearMassCoefficient ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> linearMassCoefficient: aNumber [ linearMassCoefficient := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> linearImpulseCoefficient [ ^ linearImpulseCoefficient ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> linearImpulseCoefficient: aNumber [ linearImpulseCoefficient := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> angularSoftnessEnabled [ ^ angularSoftnessEnabled ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> angularSoftnessEnabled: aBoolean [ angularSoftnessEnabled := aBoolean ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> angularBiasRate [ ^ angularBiasRate ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> angularBiasRate: aNumber [ angularBiasRate := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> angularMassCoefficient [ ^ angularMassCoefficient ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> angularMassCoefficient: aNumber [ angularMassCoefficient := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> angularImpulseCoefficient [ ^ angularImpulseCoefficient ]
{ #category : 'accessing' }
CFPhysicsPreparedWeldJoint >> angularImpulseCoefficient: aNumber [ angularImpulseCoefficient := aNumber ]

{ #category : 'writing back' }
CFPhysicsPreparedWeldJoint >> writeImpulsesBack [
	joint solverCommitTarget
		accumulatedImpulse: impulse;
		accumulatedAngularImpulse: angularImpulse
]

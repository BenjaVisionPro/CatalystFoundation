Class {
	#name : 'CFPhysicsPreparedRailJoint',
	#superclass : 'CFPhysicsPreparedJointConstraint',
	#instVars : [ 'anchorA', 'anchorB', 'axis', 'normal', 'basePerpendicularSeparation', 'perpendicularMass', 'perpendicularImpulse', 'baseTranslation', 'limitsEnabled', 'lowerTranslation', 'upperTranslation', 'translationMass', 'translationImpulse', 'baseAngle', 'angularMass', 'angularImpulse' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> anchorA [ ^ anchorA ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> anchorA: aPoint [ anchorA := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> anchorB [ ^ anchorB ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> anchorB: aPoint [ anchorB := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> axis [ ^ axis ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> axis: aPoint [ axis := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> normal [ ^ normal ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> normal: aPoint [ normal := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> basePerpendicularSeparation [ ^ basePerpendicularSeparation ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> basePerpendicularSeparation: aNumber [ basePerpendicularSeparation := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> perpendicularMass [ ^ perpendicularMass ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> perpendicularMass: aNumber [ perpendicularMass := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> perpendicularImpulse [ ^ perpendicularImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> perpendicularImpulse: aNumber [ perpendicularImpulse := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedRailJoint >> baseTranslation [ ^ baseTranslation ]
{ #category : 'limits' }
CFPhysicsPreparedRailJoint >> baseTranslation: aNumber [ baseTranslation := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedRailJoint >> limitsEnabled [ ^ limitsEnabled ]
{ #category : 'limits' }
CFPhysicsPreparedRailJoint >> limitsEnabled: aBoolean [ limitsEnabled := aBoolean ]
{ #category : 'limits' }
CFPhysicsPreparedRailJoint >> lowerTranslation [ ^ lowerTranslation ]
{ #category : 'limits' }
CFPhysicsPreparedRailJoint >> lowerTranslation: aNumber [ lowerTranslation := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedRailJoint >> upperTranslation [ ^ upperTranslation ]
{ #category : 'limits' }
CFPhysicsPreparedRailJoint >> upperTranslation: aNumber [ upperTranslation := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedRailJoint >> translationMass [ ^ translationMass ]
{ #category : 'limits' }
CFPhysicsPreparedRailJoint >> translationMass: aNumber [ translationMass := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedRailJoint >> translationImpulse [ ^ translationImpulse ]
{ #category : 'limits' }
CFPhysicsPreparedRailJoint >> translationImpulse: aNumber [ translationImpulse := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> baseAngle [ ^ baseAngle ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> baseAngle: aNumber [ baseAngle := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> angularMass [ ^ angularMass ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> angularMass: aNumber [ angularMass := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> angularImpulse [ ^ angularImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> angularImpulse: aNumber [ angularImpulse := aNumber ]

{ #category : 'writing back' }
CFPhysicsPreparedRailJoint >> writeImpulsesBack [
	joint
		accumulatedPerpendicularImpulse: perpendicularImpulse;
		accumulatedAngularImpulse: angularImpulse
]

"
I represent a prismatic joint prepared for one solver step. I hold its axis, perpendicular constraint, translation limits and angular state.
"

Class {
	#name : 'CFPhysicsPreparedPrismaticJoint',
	#superclass : 'CFPhysicsPreparedJointConstraint',
	#instVars : [ 'anchorA', 'anchorB', 'axis', 'normal', 'basePerpendicularSeparation', 'perpendicularMass', 'perpendicularImpulse', 'baseTranslation', 'limitsEnabled', 'lowerTranslation', 'upperTranslation', 'translationMass', 'translationImpulse', 'baseAngle', 'angularMass', 'angularImpulse' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> anchorA [ ^ anchorA ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> anchorA: aPoint [ anchorA := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> anchorB [ ^ anchorB ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> anchorB: aPoint [ anchorB := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> axis [ ^ axis ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> axis: aPoint [ axis := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> normal [ ^ normal ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> normal: aPoint [ normal := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> basePerpendicularSeparation [ ^ basePerpendicularSeparation ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> basePerpendicularSeparation: aNumber [ basePerpendicularSeparation := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> perpendicularMass [ ^ perpendicularMass ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> perpendicularMass: aNumber [ perpendicularMass := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> perpendicularImpulse [ ^ perpendicularImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> perpendicularImpulse: aNumber [ perpendicularImpulse := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedPrismaticJoint >> baseTranslation [ ^ baseTranslation ]
{ #category : 'limits' }
CFPhysicsPreparedPrismaticJoint >> baseTranslation: aNumber [ baseTranslation := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedPrismaticJoint >> limitsEnabled [ ^ limitsEnabled ]
{ #category : 'limits' }
CFPhysicsPreparedPrismaticJoint >> limitsEnabled: aBoolean [ limitsEnabled := aBoolean ]
{ #category : 'limits' }
CFPhysicsPreparedPrismaticJoint >> lowerTranslation [ ^ lowerTranslation ]
{ #category : 'limits' }
CFPhysicsPreparedPrismaticJoint >> lowerTranslation: aNumber [ lowerTranslation := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedPrismaticJoint >> upperTranslation [ ^ upperTranslation ]
{ #category : 'limits' }
CFPhysicsPreparedPrismaticJoint >> upperTranslation: aNumber [ upperTranslation := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedPrismaticJoint >> translationMass [ ^ translationMass ]
{ #category : 'limits' }
CFPhysicsPreparedPrismaticJoint >> translationMass: aNumber [ translationMass := aNumber ]
{ #category : 'limits' }
CFPhysicsPreparedPrismaticJoint >> translationImpulse [ ^ translationImpulse ]
{ #category : 'limits' }
CFPhysicsPreparedPrismaticJoint >> translationImpulse: aNumber [ translationImpulse := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> baseAngle [ ^ baseAngle ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> baseAngle: aNumber [ baseAngle := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> angularMass [ ^ angularMass ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> angularMass: aNumber [ angularMass := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> angularImpulse [ ^ angularImpulse ]
{ #category : 'accessing' }
CFPhysicsPreparedPrismaticJoint >> angularImpulse: aNumber [ angularImpulse := aNumber ]

{ #category : 'writing back' }
CFPhysicsPreparedPrismaticJoint >> writeImpulsesBack [
	joint solverCommitTarget
		accumulatedPerpendicularImpulse: perpendicularImpulse;
		accumulatedAngularImpulse: angularImpulse
]

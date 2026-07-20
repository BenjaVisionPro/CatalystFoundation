Class {
	#name : 'CFPhysicsPreparedRailJoint',
	#superclass : 'Object',
	#instVars : [ 'joint', 'bodyStateA', 'bodyStateB', 'anchorA', 'anchorB', 'normal', 'basePerpendicularSeparation', 'perpendicularMass', 'perpendicularImpulse', 'baseAngle', 'angularMass', 'angularImpulse' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> joint [ ^ joint ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> joint: anObject [ joint := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> firstBody [ ^ joint firstBody ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> secondBody [ ^ joint secondBody ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> bodyStateA [ ^ bodyStateA ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> bodyStateA: anObject [ bodyStateA := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> bodyStateB [ ^ bodyStateB ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> bodyStateB: anObject [ bodyStateB := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> anchorA [ ^ anchorA ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> anchorA: aPoint [ anchorA := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> anchorB [ ^ anchorB ]
{ #category : 'accessing' }
CFPhysicsPreparedRailJoint >> anchorB: aPoint [ anchorB := aPoint ]
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

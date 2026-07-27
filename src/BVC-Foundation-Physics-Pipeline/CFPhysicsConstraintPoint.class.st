Class {
	#name : 'CFPhysicsConstraintPoint',
	#superclass : 'Object',
	#instVars : [ 'manifoldPoint', 'featureId', 'anchorA', 'anchorB', 'baseSeparation', 'normalMass', 'tangentMass', 'relativeNormalVelocity', 'normalImpulse', 'tangentImpulse' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'writing back' }
CFPhysicsConstraintPoint >> writeImpulsesBack [
	manifoldPoint
		normalImpulse: normalImpulse;
		tangentImpulse: tangentImpulse
]

{ #category : 'accessing' }
CFPhysicsConstraintPoint >> manifoldPoint [ ^ manifoldPoint ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> manifoldPoint: anObject [ manifoldPoint := anObject ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> featureId [ ^ featureId ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> featureId: anObject [ featureId := anObject ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> anchorA [ ^ anchorA ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> anchorA: aPoint [ anchorA := aPoint ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> anchorB [ ^ anchorB ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> anchorB: aPoint [ anchorB := aPoint ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> baseSeparation [ ^ baseSeparation ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> baseSeparation: aNumber [ baseSeparation := aNumber ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> normalMass [ ^ normalMass ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> normalMass: aNumber [ normalMass := aNumber ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> tangentMass [ ^ tangentMass ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> tangentMass: aNumber [ tangentMass := aNumber ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> relativeNormalVelocity [ ^ relativeNormalVelocity ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> relativeNormalVelocity: aNumber [ relativeNormalVelocity := aNumber ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> normalImpulse [ ^ normalImpulse ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> normalImpulse: aNumber [ normalImpulse := aNumber ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> tangentImpulse [ ^ tangentImpulse ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> tangentImpulse: aNumber [ tangentImpulse := aNumber ]

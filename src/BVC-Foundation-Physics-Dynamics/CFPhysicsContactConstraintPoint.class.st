Class {
	#name : 'CFPhysicsContactConstraintPoint',
	#superclass : 'Object',
	#instVars : [ 'manifoldPoint', 'anchorA', 'anchorB', 'baseSeparation', 'normalMass', 'tangentMass', 'relativeNormalVelocity' ],
	#category : 'BVC-Foundation-Physics-Dynamics',
	#package : 'BVC-Foundation-Physics-Dynamics'
}

{ #category : 'instance creation' }
CFPhysicsContactConstraintPoint class >> from: aManifoldPoint [
	^ self new manifoldPoint: aManifoldPoint; yourself
]

{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> manifoldPoint [ ^ manifoldPoint ]
{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> manifoldPoint: aPoint [ manifoldPoint := aPoint ]
{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> anchorA [ ^ anchorA ]
{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> anchorA: aPoint [ anchorA := aPoint ]
{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> anchorB [ ^ anchorB ]
{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> anchorB: aPoint [ anchorB := aPoint ]
{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> baseSeparation [ ^ baseSeparation ]
{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> baseSeparation: aNumber [ baseSeparation := aNumber ]
{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> normalMass [ ^ normalMass ]
{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> normalMass: aNumber [ normalMass := aNumber ]
{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> tangentMass [ ^ tangentMass ]
{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> tangentMass: aNumber [ tangentMass := aNumber ]
{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> relativeNormalVelocity [ ^ relativeNormalVelocity ]
{ #category : 'accessing' }
CFPhysicsContactConstraintPoint >> relativeNormalVelocity: aNumber [ relativeNormalVelocity := aNumber ]

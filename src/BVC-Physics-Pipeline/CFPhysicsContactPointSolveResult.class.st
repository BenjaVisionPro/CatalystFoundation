"
I represent the post-solve result for one contact point. I preserve the point identity, world position, approach speed and solved impulses.
"

Class {
	#name : 'CFPhysicsContactPointSolveResult',
	#superclass : 'Object',
	#instVars : [ 'featureId', 'position', 'approachSpeed', 'normalImpulse', 'tangentImpulse' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactPointSolveResult class >> fromConstraintPoint: aConstraintPoint [
	^ self new
		featureId: aConstraintPoint featureId;
		position: aConstraintPoint manifoldPoint position;
		approachSpeed: aConstraintPoint relativeNormalVelocity negated;
		normalImpulse: aConstraintPoint normalImpulse;
		tangentImpulse: aConstraintPoint tangentImpulse;
		yourself
]

{ #category : 'accessing' }
CFPhysicsContactPointSolveResult >> featureId [ ^ featureId ]
{ #category : 'accessing' }
CFPhysicsContactPointSolveResult >> featureId: anObject [ featureId := anObject ]
{ #category : 'accessing' }
CFPhysicsContactPointSolveResult >> position [ ^ position ]
{ #category : 'accessing' }
CFPhysicsContactPointSolveResult >> position: aPoint [ position := aPoint ]
{ #category : 'accessing' }
CFPhysicsContactPointSolveResult >> approachSpeed [ ^ approachSpeed ]
{ #category : 'accessing' }
CFPhysicsContactPointSolveResult >> approachSpeed: aNumber [ approachSpeed := aNumber ]
{ #category : 'accessing' }
CFPhysicsContactPointSolveResult >> normalImpulse [ ^ normalImpulse ]
{ #category : 'accessing' }
CFPhysicsContactPointSolveResult >> normalImpulse: aNumber [ normalImpulse := aNumber ]
{ #category : 'accessing' }
CFPhysicsContactPointSolveResult >> tangentImpulse [ ^ tangentImpulse ]
{ #category : 'accessing' }
CFPhysicsContactPointSolveResult >> tangentImpulse: aNumber [ tangentImpulse := aNumber ]

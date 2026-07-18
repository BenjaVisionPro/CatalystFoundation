Class {
	#name : 'CFPhysicsContactSolveResult',
	#superclass : 'Object',
	#instVars : [ 'contact', 'normal', 'points' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactSolveResult class >> fromConstraint: aConstraint [
	^ self new
		contact: aConstraint contact;
		normal: aConstraint normal;
		points: (aConstraint points collect: [ :point |
			CFPhysicsContactPointSolveResult fromConstraintPoint: point ]);
		yourself
]

{ #category : 'accessing' }
CFPhysicsContactSolveResult >> contact [ ^ contact ]
{ #category : 'accessing' }
CFPhysicsContactSolveResult >> contact: anObject [ contact := anObject ]
{ #category : 'accessing' }
CFPhysicsContactSolveResult >> normal [ ^ normal ]
{ #category : 'accessing' }
CFPhysicsContactSolveResult >> normal: aPoint [ normal := aPoint ]
{ #category : 'accessing' }
CFPhysicsContactSolveResult >> points [ ^ points ]
{ #category : 'accessing' }
CFPhysicsContactSolveResult >> points: aCollection [ points := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsContactSolveResult >> totalNormalImpulse [
	^ points inject: 0.0 into: [ :sum :point | sum + point normalImpulse ]
]

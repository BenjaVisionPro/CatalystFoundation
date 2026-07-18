Class {
	#name : 'CFPhysicsConstraintPoint',
	#superclass : 'Object',
	#instVars : [ 'featureId', 'localAnchorA', 'localAnchorB', 'baseSeparation', 'normalImpulse', 'tangentImpulse' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsConstraintPoint class >> fromManifoldPoint: aPoint [
	^ self new
		featureId: aPoint featureId;
		localAnchorA: aPoint localAnchorA;
		localAnchorB: aPoint localAnchorB;
		baseSeparation: aPoint separation;
		normalImpulse: aPoint normalImpulse;
		tangentImpulse: aPoint tangentImpulse;
		yourself
]

{ #category : 'accessing' }
CFPhysicsConstraintPoint >> featureId [ ^ featureId ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> featureId: anObject [ featureId := anObject ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> localAnchorA [ ^ localAnchorA ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> localAnchorA: aPoint [ localAnchorA := aPoint ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> localAnchorB [ ^ localAnchorB ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> localAnchorB: aPoint [ localAnchorB := aPoint ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> baseSeparation [ ^ baseSeparation ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> baseSeparation: aNumber [ baseSeparation := aNumber ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> normalImpulse [ ^ normalImpulse ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> normalImpulse: aNumber [ normalImpulse := aNumber ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> tangentImpulse [ ^ tangentImpulse ]
{ #category : 'accessing' }
CFPhysicsConstraintPoint >> tangentImpulse: aNumber [ tangentImpulse := aNumber ]

Class {
	#name : 'CFPhysicsContactHitEvent',
	#superclass : 'Object',
	#instVars : [ 'contact', 'featureId', 'position', 'normal', 'approachSpeed', 'normalImpulse' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactHitEvent class >> contact: aContact normal: aNormal pointResult: aPointResult [
	^ self new
		contact: aContact;
		featureId: aPointResult featureId;
		position: aPointResult position;
		normal: aNormal;
		approachSpeed: aPointResult approachSpeed;
		normalImpulse: aPointResult normalImpulse;
		yourself
]

{ #category : 'accessing' }
CFPhysicsContactHitEvent >> contact [ ^ contact ]
{ #category : 'accessing' }
CFPhysicsContactHitEvent >> contact: anObject [ contact := anObject ]
{ #category : 'accessing' }
CFPhysicsContactHitEvent >> featureId [ ^ featureId ]
{ #category : 'accessing' }
CFPhysicsContactHitEvent >> featureId: anObject [ featureId := anObject ]
{ #category : 'accessing' }
CFPhysicsContactHitEvent >> position [ ^ position ]
{ #category : 'accessing' }
CFPhysicsContactHitEvent >> position: aPoint [ position := aPoint ]
{ #category : 'accessing' }
CFPhysicsContactHitEvent >> normal [ ^ normal ]
{ #category : 'accessing' }
CFPhysicsContactHitEvent >> normal: aPoint [ normal := aPoint ]
{ #category : 'accessing' }
CFPhysicsContactHitEvent >> approachSpeed [ ^ approachSpeed ]
{ #category : 'accessing' }
CFPhysicsContactHitEvent >> approachSpeed: aNumber [ approachSpeed := aNumber ]
{ #category : 'accessing' }
CFPhysicsContactHitEvent >> normalImpulse [ ^ normalImpulse ]
{ #category : 'accessing' }
CFPhysicsContactHitEvent >> normalImpulse: aNumber [ normalImpulse := aNumber ]

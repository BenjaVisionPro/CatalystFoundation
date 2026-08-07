"
I announce a contact impact that exceeded the configured hit threshold. I report the affected contact point, normal, approach speed and normal impulse.
"

Class {
	#name : 'CFPhysicsContactHitRecord',
	#superclass : 'Object',
	#instVars : [ 'contact', 'featureId', 'position', 'normal', 'approachSpeed', 'normalImpulse' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactHitRecord class >> contact: aContact normal: aNormal pointResult: aPointResult [
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
CFPhysicsContactHitRecord >> contact [ ^ contact ]
{ #category : 'accessing' }
CFPhysicsContactHitRecord >> contact: anObject [ contact := anObject ]
{ #category : 'accessing' }
CFPhysicsContactHitRecord >> featureId [ ^ featureId ]
{ #category : 'accessing' }
CFPhysicsContactHitRecord >> featureId: anObject [ featureId := anObject ]
{ #category : 'accessing' }
CFPhysicsContactHitRecord >> position [ ^ position ]
{ #category : 'accessing' }
CFPhysicsContactHitRecord >> position: aPoint [ position := aPoint ]
{ #category : 'accessing' }
CFPhysicsContactHitRecord >> normal [ ^ normal ]
{ #category : 'accessing' }
CFPhysicsContactHitRecord >> normal: aPoint [ normal := aPoint ]
{ #category : 'accessing' }
CFPhysicsContactHitRecord >> approachSpeed [ ^ approachSpeed ]
{ #category : 'accessing' }
CFPhysicsContactHitRecord >> approachSpeed: aNumber [ approachSpeed := aNumber ]
{ #category : 'accessing' }
CFPhysicsContactHitRecord >> normalImpulse [ ^ normalImpulse ]
{ #category : 'accessing' }
CFPhysicsContactHitRecord >> normalImpulse: aNumber [ normalImpulse := aNumber ]

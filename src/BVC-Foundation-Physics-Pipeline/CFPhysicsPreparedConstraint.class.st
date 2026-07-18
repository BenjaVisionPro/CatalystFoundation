Class {
	#name : 'CFPhysicsPreparedConstraint',
	#superclass : 'Object',
	#instVars : [ 'contact', 'normal', 'points' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsPreparedConstraint class >> fromContact: aContact [
	^ self new prepareFrom: aContact
]

{ #category : 'preparing' }
CFPhysicsPreparedConstraint >> prepareFrom: aContact [
	contact := aContact.
	normal := aContact manifold normal.
	points := aContact manifold contactPoints collect: [ :point |
		CFPhysicsConstraintPoint fromManifoldPoint: point ].
	^ self
]

{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> contact [ ^ contact ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> normal [ ^ normal ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> points [ ^ points ]

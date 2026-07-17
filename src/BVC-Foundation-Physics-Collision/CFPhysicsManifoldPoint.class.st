Class {
	#name : 'CFPhysicsManifoldPoint',
	#superclass : 'Object',
	#instVars : [ 'position', 'normalImpulse', 'tangentImpulse' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsManifoldPoint class >> at: aPoint [
	^ self new position: aPoint; yourself
]

{ #category : 'initialization' }
CFPhysicsManifoldPoint >> initialize [
	super initialize.
	normalImpulse := 0.0.
	tangentImpulse := 0.0
]

{ #category : 'accessing' }
CFPhysicsManifoldPoint >> normalImpulse [ ^ normalImpulse ]
{ #category : 'accessing' }
CFPhysicsManifoldPoint >> normalImpulse: aNumber [ normalImpulse := aNumber ]
{ #category : 'accessing' }
CFPhysicsManifoldPoint >> position [ ^ position ]
{ #category : 'accessing' }
CFPhysicsManifoldPoint >> position: aPoint [ position := aPoint ]
{ #category : 'accessing' }
CFPhysicsManifoldPoint >> tangentImpulse [ ^ tangentImpulse ]
{ #category : 'accessing' }
CFPhysicsManifoldPoint >> tangentImpulse: aNumber [ tangentImpulse := aNumber ]

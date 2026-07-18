Class {
	#name : 'CFPhysicsManifoldPoint',
	#superclass : 'Object',
	#instVars : [ 'position', 'separation', 'featureId', 'normalImpulse', 'tangentImpulse', 'localAnchorA', 'localAnchorB' ],
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
	tangentImpulse := 0.0.
	separation := 0.0.
	featureId := nil.
	localAnchorA := nil.
	localAnchorB := nil
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


{ #category : 'accessing' }
CFPhysicsManifoldPoint >> separation [ ^ separation ]
{ #category : 'accessing' }
CFPhysicsManifoldPoint >> separation: aNumber [ separation := aNumber asFloat ]
{ #category : 'accessing' }
CFPhysicsManifoldPoint >> featureId [ ^ featureId ]
{ #category : 'accessing' }
CFPhysicsManifoldPoint >> featureId: anObject [ featureId := anObject ]


{ #category : 'accessing' }
CFPhysicsManifoldPoint >> localAnchorA [ ^ localAnchorA ]

{ #category : 'accessing' }
CFPhysicsManifoldPoint >> localAnchorA: aPoint [ localAnchorA := aPoint ]

{ #category : 'accessing' }
CFPhysicsManifoldPoint >> localAnchorB [ ^ localAnchorB ]

{ #category : 'accessing' }
CFPhysicsManifoldPoint >> localAnchorB: aPoint [ localAnchorB := aPoint ]

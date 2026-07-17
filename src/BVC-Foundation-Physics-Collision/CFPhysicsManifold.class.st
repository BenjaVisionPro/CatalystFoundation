Class {
	#name : 'CFPhysicsManifold',
	#superclass : 'Object',
	#instVars : [ 'normal', 'penetration', 'contactPoints' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsManifold class >> normal: aNormal penetration: aNumber [
	^ self new normal: aNormal; penetration: aNumber; yourself
]

{ #category : 'accessing' }
CFPhysicsManifold >> contactPoints [ ^ contactPoints ]

{ #category : 'initialization' }
CFPhysicsManifold >> initialize [
	super initialize.
	contactPoints := #()
]

{ #category : 'accessing' }
CFPhysicsManifold >> normal [ ^ normal ]
{ #category : 'accessing' }
CFPhysicsManifold >> normal: aPoint [ normal := aPoint ]
{ #category : 'accessing' }
CFPhysicsManifold >> penetration [ ^ penetration ]
{ #category : 'accessing' }
CFPhysicsManifold >> penetration: aNumber [ penetration := aNumber ]

{ #category : 'accessing' }
CFPhysicsManifold >> points [
	^ contactPoints collect: [ :each | each position ]
]

{ #category : 'accessing' }
CFPhysicsManifold >> points: aCollection [
	contactPoints := aCollection collect: [ :each | CFPhysicsManifoldPoint at: each ]
]

{ #category : 'updating' }
CFPhysicsManifold >> preserveImpulsesFrom: anOldManifold [
	| count |
	anOldManifold ifNil: [ ^ self ].
	count := contactPoints size min: anOldManifold contactPoints size.
	1 to: count do: [ :index |
		(contactPoints at: index)
			normalImpulse: (anOldManifold contactPoints at: index) normalImpulse;
			tangentImpulse: (anOldManifold contactPoints at: index) tangentImpulse ]
]

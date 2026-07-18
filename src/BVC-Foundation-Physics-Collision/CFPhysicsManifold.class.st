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
	| available |
	anOldManifold ifNil: [ ^ self ].
	available := anOldManifold contactPoints asOrderedCollection.
	contactPoints do: [ :point |
		| nearest |
		available ifNotEmpty: [
			nearest := available first.
			available allButFirst do: [ :candidate |
				(candidate position distanceTo: point position)
					< (nearest position distanceTo: point position)
					ifTrue: [ nearest := candidate ] ].
			point
				normalImpulse: nearest normalImpulse;
				tangentImpulse: nearest tangentImpulse.
			available remove: nearest ] ]
]

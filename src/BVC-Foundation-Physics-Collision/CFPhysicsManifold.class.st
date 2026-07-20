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



{ #category : 'accessing' }
CFPhysicsManifold >> contactPoints: aCollection [
	contactPoints := aCollection asArray
]

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
CFPhysicsManifold >> clearImpulses [
	contactPoints do: [ :point |
		point
			normalImpulse: 0.0;
			tangentImpulse: 0.0 ]
]

{ #category : 'updating' }
CFPhysicsManifold >> preserveImpulsesFrom: anOldManifold [
	anOldManifold ifNil: [ ^ self ].
	(self hasCompatibleNormalWith: anOldManifold) ifFalse: [ ^ self ].
	contactPoints do: [ :point |
		point featureId ifNotNil: [ :featureId |
			anOldManifold contactPoints
				detect: [ :oldPoint | oldPoint featureId = featureId ]
				ifFound: [ :oldPoint |
					point
						normalImpulse: oldPoint normalImpulse;
						tangentImpulse: oldPoint tangentImpulse ] ] ]
]

{ #category : 'testing' }
CFPhysicsManifold >> hasCompatibleNormalWith: anotherManifold [
	(normal isNil or: [ anotherManifold normal isNil ]) ifTrue: [ ^ true ].
	^ (normal dotProduct: anotherManifold normal) > 0.0
]

"
I represent the contact geometry between two overlapping shapes.

I own the collision normal, penetration depth and manifold points whose impulses may be preserved across simulation steps.
"
Class {
	#name : 'CFPhysicsManifold',
	#superclass : 'Object',
	#instVars : [ 'normal', 'penetration', 'contactPoints', 'rollingImpulse' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
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
	contactPoints := #().
	rollingImpulse := 0.0
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
	rollingImpulse := 0.0.
	contactPoints do: [ :point |
		point
			normalImpulse: 0.0;
			tangentImpulse: 0.0 ]
]

{ #category : 'updating' }
CFPhysicsManifold >> preserveImpulsesFrom: anOldManifold [
	anOldManifold ifNil: [ ^ self ].
	rollingImpulse := anOldManifold rollingImpulse.
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


{ #category : 'accessing' }
CFPhysicsManifold >> rollingImpulse [ ^ rollingImpulse ]

{ #category : 'accessing' }
CFPhysicsManifold >> rollingImpulse: aNumber [ rollingImpulse := aNumber asFloat ]

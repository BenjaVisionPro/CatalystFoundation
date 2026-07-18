Class {
	#name : 'CFPhysicsContact',
	#superclass : 'Object',
	#instVars : [ 'pair', 'manifold', 'previousManifold' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsContact class >> pair: aPair manifold: aManifold [
	^ self new pair: aPair; manifold: aManifold; yourself
]

{ #category : 'accessing' }
CFPhysicsContact >> pair [ ^ pair ]

{ #category : 'accessing' }
CFPhysicsContact >> pair: aPair [ pair := aPair ]

{ #category : 'accessing' }
CFPhysicsContact >> key [ ^ pair key ]

{ #category : 'accessing' }
CFPhysicsContact >> firstBody [ ^ pair firstBody ]

{ #category : 'accessing' }
CFPhysicsContact >> secondBody [ ^ pair secondBody ]

{ #category : 'accessing' }
CFPhysicsContact >> manifold [ ^ manifold ]

{ #category : 'accessing' }
CFPhysicsContact >> manifold: aManifold [ manifold := aManifold ]

{ #category : 'accessing' }
CFPhysicsContact >> previousManifold [ ^ previousManifold ]

{ #category : 'testing' }
CFPhysicsContact >> began [ ^ previousManifold isNil and: [ manifold notNil ] ]

{ #category : 'testing' }
CFPhysicsContact >> continued [ ^ previousManifold notNil and: [ manifold notNil ] ]

{ #category : 'testing' }
CFPhysicsContact >> ended [ ^ previousManifold notNil and: [ manifold isNil ] ]

{ #category : 'testing' }
CFPhysicsContact >> isTouching [ ^ manifold notNil ]

{ #category : 'updating' }
CFPhysicsContact >> updateWith: aManifold [
	previousManifold := manifold.
	aManifold ifNotNil: [ aManifold preserveImpulsesFrom: previousManifold ].
	manifold := aManifold
]

{ #category : 'copying' }
CFPhysicsContact >> copyForUpdate [
	^ self class new
		pair: pair;
		manifold: manifold;
		yourself
]


{ #category : 'testing' }
CFPhysicsContact >> isSensor [
	^ self firstBody isSensor or: [ self secondBody isSensor ]
]

{ #category : 'testing' }
CFPhysicsContact >> isSolid [
	^ self isSensor not
]

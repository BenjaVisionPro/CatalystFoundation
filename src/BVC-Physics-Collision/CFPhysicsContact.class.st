"
I represent the persistent contact relationship between a pair of bodies.

I retain the current and previous manifolds and shape snapshots needed to classify and continue the contact across steps.
"
Class {
	#name : 'CFPhysicsContact',
	#superclass : 'Object',
	#instVars : [ 'pair', 'manifold', 'previousManifold', 'firstShapeState', 'secondShapeState' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
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


{ #category : 'accessing' }
CFPhysicsContact >> shapeStatesFromBodyStates: bodyStates [
	firstShapeState := pair firstShape isChainSegment
		ifTrue: [ pair firstShape ]
		ifFalse: [ (bodyStates at: pair firstBody) shapeState ].
	secondShapeState := pair secondShape isChainSegment
		ifTrue: [ pair secondShape ]
		ifFalse: [ (bodyStates at: pair secondBody) shapeState ]
]

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
	aManifold ifNotNil: [
		aManifold preserveImpulsesFrom: previousManifold.
		self isSensor ifTrue: [ aManifold clearImpulses ] ].
	manifold := aManifold
]


{ #category : 'updating' }
CFPhysicsContact >> updateFromPreviousContact: aPreviousContact with: aManifold [
	previousManifold := aPreviousContact
		ifNil: [ nil ]
		ifNotNil: [ aPreviousContact manifold ].
	aManifold ifNotNil: [
		aManifold preserveImpulsesFrom: previousManifold.
		self isSensor ifTrue: [ aManifold clearImpulses ] ].
	manifold := aManifold
]

{ #category : 'copying' }
CFPhysicsContact >> copyForUpdate [
	^ self class new
		pair: pair;
		manifold: manifold;
		firstShapeState: firstShapeState;
		secondShapeState: secondShapeState;
		yourself
]



{ #category : 'private - accessing' }
CFPhysicsContact >> firstShapeState: aShapeState [ firstShapeState := aShapeState ]

{ #category : 'private - accessing' }
CFPhysicsContact >> secondShapeState: aShapeState [ secondShapeState := aShapeState ]

{ #category : 'testing' }
CFPhysicsContact >> isSensor [
	^ firstShapeState isSensor or: [ secondShapeState isSensor ]
]

{ #category : 'testing' }
CFPhysicsContact >> isSolid [
	^ self isSensor not
]


{ #category : 'islands' }
CFPhysicsContact >> bodyA [
	"First body endpoint for persistent island graph linkage."
	^ self firstBody
]

{ #category : 'islands' }
CFPhysicsContact >> bodyB [
	"Second body endpoint for persistent island graph linkage."
	^ self secondBody
]

"I retain the feature indexes of the final GJK simplex for a persistent contact.

I mirror Box2D's b2SimplexCache. Indexes are one-based because Physics collections are one-based."
Class {
	#name : 'CFPhysicsSimplexCache',
	#superclass : 'Object',
	#instVars : [ 'firstIndexes', 'secondIndexes' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsSimplexCache class >> empty [
	^ self new clear; yourself
]

{ #category : 'initialization' }
CFPhysicsSimplexCache >> clear [
	firstIndexes := #().
	secondIndexes := #()
]

{ #category : 'accessing' }
CFPhysicsSimplexCache >> count [
	^ firstIndexes size
]

{ #category : 'accessing' }
CFPhysicsSimplexCache >> firstIndexAt: anIndex [
	^ firstIndexes at: anIndex
]

{ #category : 'accessing' }
CFPhysicsSimplexCache >> secondIndexAt: anIndex [
	^ secondIndexes at: anIndex
]

{ #category : 'testing' }
CFPhysicsSimplexCache >> isValidForFirstProxy: firstProxy secondProxy: secondProxy [
	firstIndexes size = secondIndexes size ifFalse: [ ^ false ].
	firstIndexes size > 3 ifTrue: [ ^ false ].
	1 to: firstIndexes size do: [ :index |
		((firstIndexes at: index) between: 1 and: firstProxy points size) ifFalse: [ ^ false ].
		((secondIndexes at: index) between: 1 and: secondProxy points size) ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'updating' }
CFPhysicsSimplexCache >> updateFromSimplex: aSimplex [
	firstIndexes := (aSimplex collect: [ :vertex | vertex firstIndex ]) asArray.
	secondIndexes := (aSimplex collect: [ :vertex | vertex secondIndex ]) asArray
]

"I explicitly supply a freshly materialized object by evaluating a factory block.

Each materialize invokes the factory once and answers its result. A caller should materialize once for a composition interaction and pass that candidate to the operation so reassessment does not silently change candidate identity."
Class {
	#name : 'CFAtelierFactoryProvider',
	#superclass : 'CFAtelierObjectProvider',
	#instVars : [
		'factory'
	],
	#category : 'BVC-Foundation-Atelier-Supply',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Supply'
}

{ #category : 'instance creation' }
CFAtelierFactoryProvider class >> factory: aBlock [
	^ self new
		factory: aBlock;
		yourself
]

{ #category : 'accessing' }
CFAtelierFactoryProvider >> factory [
	^ factory
]

{ #category : 'accessing' }
CFAtelierFactoryProvider >> factory: aBlock [
	factory := aBlock
]

{ #category : 'materializing' }
CFAtelierFactoryProvider >> materialize [
	^ factory value
]

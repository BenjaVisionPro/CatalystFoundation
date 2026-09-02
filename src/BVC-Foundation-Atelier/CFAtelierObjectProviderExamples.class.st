"I prove the minimal Atelier object-supply semantics independently of palettes, storage and serialization."
Class {
	#name : 'CFAtelierObjectProviderExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - supply' }
CFAtelierObjectProviderExamples >> existingObjectProviderPreservesIdentity [
	<gtExample>
	| object provider first second |
	object := Object new.
	provider := CFAtelierExistingObjectProvider object: object.

	first := provider materialize.
	second := provider materialize.

	self assert: first == object.
	self assert: second == object.
	self assert: first == second.
	^ provider
]

{ #category : 'examples - supply' }
CFAtelierObjectProviderExamples >> factoryProviderMaterializesFreshObjects [
	<gtExample>
	| provider first second |
	provider := CFAtelierFactoryProvider factory: [ Object new ].

	first := provider materialize.
	second := provider materialize.

	self assert: first ~~ second.
	^ provider
]

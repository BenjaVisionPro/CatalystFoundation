"I provide executable examples for Foundation Magritte transactions that include embedded relation objects."

Class {
	#name : 'CFMaEmbeddedTransactionExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples - identity' }
CFMaEmbeddedTransactionExamples >> childMementoIdentityIsStable [
	<gtExample>
	| aModel aMemento aDescription anObject firstMemento secondMemento |
	aModel := CFMaFormShowcase example.
	aMemento := CFMaMemento model: aModel.
	aDescription := aMemento magritteDescription
		detect: [ :each | each handlesSelector: #embeddedObject ].
	anObject := aModel embeddedObject.

	firstMemento := aMemento
		childMementoFor: anObject
		inRelation: aDescription.
	secondMemento := aMemento
		childMementoFor: anObject
		inRelation: aDescription.

	self assert: firstMemento == secondMemento.
	^ firstMemento
]

{ #category : 'examples - identity' }
CFMaEmbeddedTransactionExamples >> removedRelationObjectReleasesChildMemento [
	<gtExample>
	| aModel aMemento aDescription anObject firstMemento secondMemento |
	aModel := CFMaFormShowcase example.
	aMemento := CFMaMemento model: aModel.
	aDescription := aMemento magritteDescription
		detect: [ :each | each handlesSelector: #embeddedObject ].
	anObject := aModel embeddedObject.

	firstMemento := aMemento
		childMementoFor: anObject
		inRelation: aDescription.
	aMemento
		retainChildMementosFor: #()
		inRelation: aDescription.
	secondMemento := aMemento
		childMementoFor: anObject
		inRelation: aDescription.

	self assert: (firstMemento == secondMemento) not.
	^ secondMemento
]

{ #category : 'examples - transaction' }
CFMaEmbeddedTransactionExamples >> resetRestoresEmbeddedValue [
	<gtExample>
	| aModel aMemento aRelationDescription anObject aChildMemento aScoreDescription |
	aModel := CFMaFormShowcase example.
	aMemento := CFMaMemento model: aModel.
	aRelationDescription := aMemento magritteDescription
		detect: [ :each | each handlesSelector: #embeddedObject ].
	anObject := aModel embeddedObject.
	aChildMemento := aMemento
		childMementoFor: anObject
		inRelation: aRelationDescription.
	aScoreDescription := aChildMemento magritteDescription
		detect: [ :each | each handlesSelector: #score ].

	aChildMemento write: 45 using: aScoreDescription.
	self assert: (aChildMemento readUsing: aScoreDescription) equals: 45.
	self assert: anObject score equals: 30.

	aMemento reset.

	self assert: (aChildMemento readUsing: aScoreDescription) equals: 30.
	self assert: anObject score equals: 30.
	^ aMemento
]

{ #category : 'examples - transaction' }
CFMaEmbeddedTransactionExamples >> commitWritesEmbeddedValue [
	<gtExample>
	| aModel aMemento aRelationDescription anObject aChildMemento aScoreDescription |
	aModel := CFMaFormShowcase example.
	aMemento := CFMaMemento model: aModel.
	aRelationDescription := aMemento magritteDescription
		detect: [ :each | each handlesSelector: #embeddedObject ].
	anObject := aModel embeddedObject.
	aChildMemento := aMemento
		childMementoFor: anObject
		inRelation: aRelationDescription.
	aScoreDescription := aChildMemento magritteDescription
		detect: [ :each | each handlesSelector: #score ].

	aChildMemento write: 45 using: aScoreDescription.
	aMemento commit.

	self assert: anObject score equals: 45.
	self assert: (aChildMemento readUsing: aScoreDescription) equals: 45.
	^ aMemento
]

{ #category : 'examples - identity' }
CFMaEmbeddedTransactionExamples >> relationIdentityIncludesOrder [
	<gtExample>
	| aModel alpha beta firstViewModel secondViewModel theViewModels |
	aModel := CFMaFormShowcase example.
	alpha := aModel embeddedItems first.
	beta := aModel embeddedItems second.
	firstViewModel := CFMaViewModel forObject: alpha.
	secondViewModel := CFMaViewModel forObject: beta.
	theViewModels := { firstViewModel. secondViewModel }.

	self assert: (CFMaBuilderUtility
		relationModels: { alpha. beta }
		matchViewModels: theViewModels).
	self assert: (CFMaBuilderUtility
		relationModels: { beta. alpha }
		matchViewModels: theViewModels) not.
	^ theViewModels
]

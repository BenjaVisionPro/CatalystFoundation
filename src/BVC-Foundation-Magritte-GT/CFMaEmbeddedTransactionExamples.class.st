"
I provide executable examples for Foundation Magritte transactions that include embedded relation objects.
"
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

{ #category : 'examples - compact identity' }
CFMaEmbeddedTransactionExamples >> labelledObjectMementoCarriesDefaultCompactIdentityReference [
	<gtExample>
	| anObject aMemento aReference |
	anObject := CFMaFormShowcaseItem exampleNamed: 'Alpha' score: 10 status: #active.
	aMemento := CFMaMemento model: anObject.
	aReference := aMemento magritteDescription compactIdentityReference.

	self assert: aReference isNotNil.
	self assert: aReference asContainer children size equals: 3.
	self assert: aReference asContainer children first accessor readSelector equals: #icon.
	self assert: aReference asContainer children second accessor readSelector equals: #label.
	self assert: aReference asContainer children third accessor readSelector equals: #identifier.
	^ aMemento
]

{ #category : 'examples - compact identity' }
CFMaEmbeddedTransactionExamples >> embeddedChildMementoCarriesDefaultCompactIdentityReference [
	<gtExample>
	| aModel anObject aDescription aParentMemento aChildMemento |
	aModel := CFMaFormShowcase new.
	anObject := CFMaFormShowcaseItem exampleNamed: 'Alpha' score: 10 status: #active.
	aModel listObject: anObject.
	aDescription := aModel listObjectDescription.
	aParentMemento := CFMaMemento model: aModel.
	aChildMemento := aParentMemento childMementoFor: anObject inRelation: aDescription.

	self assert: aChildMemento magritteDescription compactIdentityReference isNotNil.
	self assert: aChildMemento magritteDescription compactIdentityReference asContainer children size equals: 3.
	^ aChildMemento
]

{ #category : 'examples - compact identity' }
CFMaEmbeddedTransactionExamples >> explicitContainerCompactIdentityReferenceOverridesObjectDefault [
	<gtExample>
	| anObject aDescription anExplicitReference aMemento |
	anObject := CFMaFormShowcaseItem exampleNamed: 'Alpha' score: 10 status: #active.
	anExplicitReference := anObject labelDescription asContainer.
	aDescription := anObject magritteDescription
		compactIdentityReference: anExplicitReference;
		yourself.
	aMemento := CFMaMemento model: anObject description: aDescription.

	self assert: aMemento magritteDescription compactIdentityReference == anExplicitReference.
	^ aMemento
]



{ #category : 'examples - transaction' }
CFMaEmbeddedTransactionExamples >> resetReleasesChildMementoForStagedInsertion [
	<gtExample>
	| model parentMemento relationDescription candidate operation childMemento scoreDescription |
	model := CFMaFormShowcase example.
	model embeddedItems: model embeddedItems asOrderedCollection.
	parentMemento := CFMaMemento model: model.
	relationDescription := parentMemento magritteDescription
		detect: [ :each | each handlesSelector: #embeddedItems ].
	candidate := CFMaFormShowcaseItem exampleNamed: 'Inserted' score: 10 status: #active.
	operation := CFAtelierInsert
		object: candidate
		memento: parentMemento
		description: relationDescription.

	self assert: operation apply isApplicable.
	childMemento := parentMemento
		childMementoFor: candidate
		inRelation: relationDescription.
	scoreDescription := childMemento magritteDescription
		detect: [ :each | each handlesSelector: #score ].
	childMemento write: 45 using: scoreDescription.

	parentMemento reset.

	self assert: ((parentMemento readUsing: relationDescription) identityIncludes: candidate) not.
	self assert: (parentMemento allChildMementos identityIncludes: childMemento) not.
	self assert: candidate score equals: 10.
	^ parentMemento
]

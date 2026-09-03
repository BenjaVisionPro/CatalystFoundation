"I prove generic Atelier replacement semantics independently of presentation/direct-manipulation mechanics."
Class {
	#name : 'CFAtelierReplaceExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - assessment' }
CFAtelierReplaceExamples >> assessmentPreservesOrderedPositionWithoutMutation [
	<gtExample>
	| model memento alpha beta gamma replacement description operation assessment |
	model := CFAtelierReplaceExampleModel new.
	alpha := Object new.
	beta := Object new.
	gamma := Object new.
	replacement := Object new.
	model items: (OrderedCollection with: alpha with: beta with: gamma).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #items in: memento.
	operation := CFAtelierReplace
		object: beta
		with: replacement
		memento: memento
		description: description.

	assessment := operation assess.

	self assert: assessment isApplicable.
	self assert: assessment replacementIndex equals: 2.
	self assert: assessment proposedValue first == alpha.
	self assert: assessment proposedValue second == replacement.
	self assert: assessment proposedValue third == gamma.
	self assert: (memento readUsing: description) second == beta.
	self assert: model items second == beta.
	^ assessment
]

{ #category : 'examples - transaction' }
CFAtelierReplaceExamples >> applyStagesToOneReplacementWithoutMutatingModel [
	<gtExample>
	| model memento original replacement description operation assessment |
	model := CFAtelierReplaceExampleModel new.
	original := Object new.
	replacement := Object new.
	model primaryItem: original.
	memento := CFMaMemento model: model.
	description := self descriptionFor: #primaryItem in: memento.
	operation := CFAtelierReplace
		object: original
		with: replacement
		memento: memento
		description: description.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) == replacement.
	self assert: model primaryItem == original.
	^ memento
]

{ #category : 'examples - transaction' }
CFAtelierReplaceExamples >> commitPreservesReplacementIdentity [
	<gtExample>
	| model memento original replacement description operation |
	model := CFAtelierReplaceExampleModel new.
	original := Object new.
	replacement := Object new.
	model items: (OrderedCollection with: original).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #items in: memento.
	operation := CFAtelierReplace
		object: original
		with: replacement
		memento: memento
		description: description.

	self assert: operation apply isApplicable.
	memento commit.

	self assert: model items size equals: 1.
	self assert: model items first == replacement.
	^ model
]

{ #category : 'examples - assessment' }
CFAtelierReplaceExamples >> duplicateSourceIdentityIsRejected [
	<gtExample>
	| model memento source replacement description operation assessment |
	model := CFAtelierReplaceExampleModel new.
	source := Object new.
	replacement := Object new.
	model items: (OrderedCollection with: source with: source).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #items in: memento.
	operation := CFAtelierReplace
		object: source
		with: replacement
		memento: memento
		description: description.

	assessment := operation apply.

	self assert: assessment isApplicable not.
	self assert: assessment rejectionMessage equals: 'The replaced object must occur exactly once in the relation.'.
	self assert: (memento readUsing: description) size equals: 2.
	self assert: model items size equals: 2.
	^ assessment
]

{ #category : 'examples - transaction' }
CFAtelierReplaceExamples >> applyReassessesCurrentStagedState [
	<gtExample>
	| model memento alpha source replacement description operation hoverAssessment applyAssessment |
	model := CFAtelierReplaceExampleModel new.
	alpha := Object new.
	source := Object new.
	replacement := Object new.
	model items: (OrderedCollection with: alpha with: source).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #items in: memento.
	operation := CFAtelierReplace
		object: source
		with: replacement
		memento: memento
		description: description.

	hoverAssessment := operation assess.
	self assert: hoverAssessment isApplicable.
	memento
		write: (OrderedCollection with: alpha)
		using: description.

	applyAssessment := operation apply.

	self assert: applyAssessment isApplicable not.
	self assert: applyAssessment rejectionMessage equals: 'The replaced object must occur exactly once in the relation.'.
	self assert: (memento readUsing: description) size equals: 1.
	self assert: (memento readUsing: description) first == alpha.
	self assert: model items size equals: 2.
	^ applyAssessment
]

{ #category : 'private' }
CFAtelierReplaceExamples >> descriptionFor: aSelector in: aMemento [
	^ aMemento magritteDescription
		detect: [ :each | each handlesSelector: aSelector ]
]

{ #category : 'examples - embedded transaction' }
CFAtelierReplaceExamples >> commitDoesNotCommitReplacedEmbeddedEdits [
	<gtExample>
	| model original replacement parentMemento relationDescription childMemento nameDescription operation |
	model := CFAtelierReplaceExampleModel new.
	original := CFAtelierEntryExampleModel new.
	replacement := CFAtelierEntryExampleModel new.
	model items: (OrderedCollection with: original).
	parentMemento := CFMaMemento model: model.
	relationDescription := self descriptionFor: #items in: parentMemento.
	childMemento := parentMemento childMementoFor: original inRelation: relationDescription.
	nameDescription := self descriptionFor: #name in: childMemento.
	childMemento write: 'Staged original name' using: nameDescription.

	operation := CFAtelierReplace
		object: original
		with: replacement
		memento: parentMemento
		description: relationDescription.
	self assert: operation apply isApplicable.
	parentMemento commit.

	self assert: model items size equals: 1.
	self assert: model items first == replacement.
	self assert: original name equals: 'Atelier example'.
	^ parentMemento
]


{ #category : 'examples - assessment' }
CFAtelierReplaceExamples >> replacementIdentityAlreadyInTargetIsRejected [
	<gtExample>
	| model memento source replacement description operation assessment |
	model := CFAtelierReplaceExampleModel new.
	source := Object new.
	replacement := Object new.
	model items: (OrderedCollection with: source with: replacement).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #items in: memento.
	operation := CFAtelierReplace
		object: source
		with: replacement
		memento: memento
		description: description.

	assessment := operation apply.

	self assert: assessment isApplicable not.
	self assert: assessment rejectionMessage equals: 'The replacement object is already present in the target relation.'.
	self assert: (memento readUsing: description) size equals: 2.
	self assert: (memento readUsing: description) first == source.
	self assert: (memento readUsing: description) second == replacement.
	self assert: model items size equals: 2.
	^ assessment
]

"I provide the first executable contract for Foundation Atelier: one semantic move spanning two existing Magritte relation editing contexts."
Class {
	#name : 'CFAtelierMoveExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - assessment' }
CFAtelierMoveExamples >> assessmentDoesNotMutateEditingState [
	<gtExample>
	| fixture model memento alpha beta gamma move assessment leftDescription rightDescription |
	fixture := self fixture.
	model := fixture first.
	memento := fixture second.
	alpha := fixture third.
	beta := fixture fourth.
	gamma := fixture fifth.
	leftDescription := self descriptionFor: #leftItems in: memento.
	rightDescription := self descriptionFor: #rightItems in: memento.

	move := self
		move: beta
		memento: memento
		left: leftDescription
		right: rightDescription
		at: 2.
	assessment := move assess.

	self assert: assessment isApplicable.
	self assert: ((memento readUsing: leftDescription) at: 1) == alpha.
	self assert: ((memento readUsing: leftDescription) at: 2) == beta.
	self assert: ((memento readUsing: rightDescription) at: 1) == gamma.
	self assert: model leftItems second == beta.
	self assert: model rightItems first == gamma.
	self assert: assessment proposedSourceItems size equals: 1.
	self assert: assessment proposedSourceItems first == alpha.
	self assert: assessment proposedDestinationItems first == gamma.
	self assert: assessment proposedDestinationItems second == beta.
	^ assessment
]

{ #category : 'examples - transaction' }
CFAtelierMoveExamples >> applyStagesMoveWithoutMutatingModel [
	<gtExample>
	| fixture model memento alpha beta gamma move assessment leftDescription rightDescription |
	fixture := self fixture.
	model := fixture first.
	memento := fixture second.
	alpha := fixture third.
	beta := fixture fourth.
	gamma := fixture fifth.
	leftDescription := self descriptionFor: #leftItems in: memento.
	rightDescription := self descriptionFor: #rightItems in: memento.

	move := self
		move: beta
		memento: memento
		left: leftDescription
		right: rightDescription
		at: 2.
	assessment := move apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: leftDescription) first == alpha.
	self assert: (memento readUsing: leftDescription) size equals: 1.
	self assert: (memento readUsing: rightDescription) first == gamma.
	self assert: (memento readUsing: rightDescription) second == beta.
	self assert: model leftItems size equals: 2.
	self assert: model leftItems second == beta.
	self assert: model rightItems size equals: 1.
	self assert: model rightItems first == gamma.
	^ memento
]

{ #category : 'examples - transaction' }
CFAtelierMoveExamples >> commitAppliesMoveAndPreservesIdentity [
	<gtExample>
	| fixture model memento alpha beta gamma move leftDescription rightDescription |
	fixture := self fixture.
	model := fixture first.
	memento := fixture second.
	alpha := fixture third.
	beta := fixture fourth.
	gamma := fixture fifth.
	leftDescription := self descriptionFor: #leftItems in: memento.
	rightDescription := self descriptionFor: #rightItems in: memento.

	move := self
		move: beta
		memento: memento
		left: leftDescription
		right: rightDescription
		at: 2.
	self assert: move apply isApplicable.
	memento commit.

	self assert: model leftItems size equals: 1.
	self assert: model leftItems first == alpha.
	self assert: model rightItems size equals: 2.
	self assert: model rightItems first == gamma.
	self assert: model rightItems second == beta.
	^ model
]

{ #category : 'private' }
CFAtelierMoveExamples >> descriptionFor: aSelector in: aMemento [
	^ aMemento magritteDescription
		detect: [ :each | each handlesSelector: aSelector ]
]

{ #category : 'examples - assessment' }
CFAtelierMoveExamples >> destinationValidationRejectsWithoutMutation [
	<gtExample>
	| fixture model memento beta move assessment leftDescription rightDescription |
	fixture := self fixture.
	model := fixture first.
	memento := fixture second.
	beta := fixture fourth.
	model rightItemLimit: 1.
	memento reset.
	leftDescription := self descriptionFor: #leftItems in: memento.
	rightDescription := self descriptionFor: #rightItems in: memento.

	move := self
		move: beta
		memento: memento
		left: leftDescription
		right: rightDescription
		at: 2.
	assessment := move apply.

	self assert: assessment isApplicable not.
	self assert: assessment rejectionMessage equals: 'The right relation has reached its configured limit.'.
	self assert: (memento readUsing: leftDescription) size equals: 2.
	self assert: (memento readUsing: rightDescription) size equals: 1.
	self assert: model leftItems size equals: 2.
	self assert: model rightItems size equals: 1.
	^ assessment
]

{ #category : 'private' }
CFAtelierMoveExamples >> fixture [
	| model memento alpha beta gamma |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	beta := Object new.
	gamma := Object new.
	model
		leftItems: (OrderedCollection with: alpha with: beta);
		rightItems: (OrderedCollection with: gamma).
	memento := CFMaMemento model: model.
	^ { model. memento. alpha. beta. gamma }
]

{ #category : 'examples - current foundation boundary' }
CFAtelierMoveExamples >> movedEmbeddedChildCurrentlyReceivesANewRelationScopedMemento [
	<gtExample>
	| model parentMemento item leftDescription rightDescription childMemento scoreDescription move destinationChildMemento destinationScoreDescription |
	model := CFAtelierMoveExampleModel new.
	item := CFMaFormShowcaseItem exampleNamed: 'Alpha' score: 30 status: #active.
	model
		leftItems: (OrderedCollection with: item);
		rightItems: OrderedCollection new.
	parentMemento := CFMaMemento model: model.
	leftDescription := self descriptionFor: #leftItems in: parentMemento.
	rightDescription := self descriptionFor: #rightItems in: parentMemento.
	childMemento := parentMemento childMementoFor: item inRelation: leftDescription.
	scoreDescription := self descriptionFor: #score in: childMemento.
	childMemento write: 45 using: scoreDescription.

	move := self
		move: item
		memento: parentMemento
		left: leftDescription
		right: rightDescription
		at: 1.
	self assert: move apply isApplicable.
	parentMemento
		retainChildMementosFor: (parentMemento readUsing: leftDescription)
		inRelation: leftDescription.
	destinationChildMemento := parentMemento childMementoFor: item inRelation: rightDescription.
	destinationScoreDescription := self descriptionFor: #score in: destinationChildMemento.

	self assert: destinationChildMemento ~~ childMemento.
	self assert: (destinationChildMemento readUsing: destinationScoreDescription) equals: 30.
	self assert: item score equals: 30.
	^ destinationChildMemento
]

{ #category : 'private' }
CFAtelierMoveExamples >> move: anObject memento: aMemento left: leftDescription right: rightDescription at: anIndex [
	^ CFAtelierMove
		object: anObject
		sourceMemento: aMemento
		sourceDescription: leftDescription
		destinationMemento: aMemento
		destinationDescription: rightDescription
		destinationIndex: anIndex
]

{ #category : 'examples - transaction' }
CFAtelierMoveExamples >> resetRestoresStagedMove [
	<gtExample>
	| fixture model memento beta move leftDescription rightDescription |
	fixture := self fixture.
	model := fixture first.
	memento := fixture second.
	beta := fixture fourth.
	leftDescription := self descriptionFor: #leftItems in: memento.
	rightDescription := self descriptionFor: #rightItems in: memento.
	move := self
		move: beta
		memento: memento
		left: leftDescription
		right: rightDescription
		at: 2.

	self assert: move apply isApplicable.
	self assert: (memento readUsing: leftDescription) size equals: 1.
	self assert: (memento readUsing: rightDescription) size equals: 2.
	memento reset.

	self assert: (memento readUsing: leftDescription) size equals: 2.
	self assert: (memento readUsing: leftDescription) second == beta.
	self assert: (memento readUsing: rightDescription) size equals: 1.
	self assert: model leftItems second == beta.
	^ memento
]

{ #category : 'examples - assessment' }
CFAtelierMoveExamples >> applyReassessesCurrentStagedState [
	<gtExample>
	| fixture model memento beta delta move hoverAssessment applyAssessment leftDescription rightDescription |
	fixture := self fixture.
	model := fixture first.
	memento := fixture second.
	beta := fixture fourth.
	model rightItemLimit: 2.
	memento reset.
	leftDescription := self descriptionFor: #leftItems in: memento.
	rightDescription := self descriptionFor: #rightItems in: memento.
	move := self
		move: beta
		memento: memento
		left: leftDescription
		right: rightDescription
		at: 2.

	hoverAssessment := move assess.
	self assert: hoverAssessment isApplicable.

	delta := Object new.
	rightDescription validate: (OrderedCollection with: model rightItems first with: delta).
	memento
		write: (OrderedCollection with: model rightItems first with: delta)
		using: rightDescription.

	applyAssessment := move apply.
	self assert: applyAssessment isApplicable not.
	self assert: (memento readUsing: leftDescription) size equals: 2.
	self assert: (memento readUsing: leftDescription) second == beta.
	self assert: (memento readUsing: rightDescription) size equals: 2.
	self assert: model rightItems size equals: 1.
	^ applyAssessment
]

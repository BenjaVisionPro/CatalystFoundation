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
	self assert: assessment rejectionMessage equals: 'Right: The right relation has reached its configured limit.'.
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

{ #category : 'examples - embedded editing state' }
CFAtelierMoveExamples >> movedEmbeddedChildKeepsItsRelationScopedMementoAndStagedState [
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

	self assert: destinationChildMemento == childMemento.
	self assert: (destinationChildMemento readUsing: destinationScoreDescription) equals: 45.
	self assert: item score equals: 30.
	^ destinationChildMemento
]

{ #category : 'examples - embedded editing state' }
CFAtelierMoveExamples >> movedEmbeddedChildCommitsThroughDestinationContext [
	<gtExample>
	| model parentMemento item leftDescription rightDescription childMemento scoreDescription move |
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
	parentMemento commit.

	self assert: model leftItems isEmpty.
	self assert: model rightItems first == item.
	self assert: item score equals: 45.
	^ model
]


{ #category : 'examples - embedded editing state' }
CFAtelierMoveExamples >> resetRestoresTransferredChildMementoToSourceRelationContext [
	<gtExample>
	| model parentMemento item leftDescription rightDescription childMemento scoreDescription move restoredChildMemento restoredScoreDescription |
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
	self assert: (parentMemento childMementoFor: item inRelation: rightDescription) == childMemento.

	parentMemento reset.
	restoredChildMemento := parentMemento childMementoFor: item inRelation: leftDescription.
	restoredScoreDescription := self descriptionFor: #score in: restoredChildMemento.

	self assert: restoredChildMemento == childMemento.
	self assert: (restoredChildMemento readUsing: restoredScoreDescription) equals: 30.
	self assert: (parentMemento readUsing: leftDescription) first == item.
	self assert: (parentMemento readUsing: rightDescription) isEmpty.
	self assert: model leftItems first == item.
	self assert: model rightItems isEmpty.
	^ restoredChildMemento
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

{ #category : 'examples - cardinality' }
CFAtelierMoveExamples >> moveFromToOneIntoOrderedToMany [
	<gtExample>
	| model memento alpha gamma leftItemDescription rightItemsDescription operation assessment |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	gamma := Object new.
	model
		leftItem: alpha;
		rightItems: (OrderedCollection with: gamma).
	memento := CFMaMemento model: model.
	leftItemDescription := self descriptionFor: #leftItem in: memento.
	rightItemsDescription := self descriptionFor: #rightItems in: memento.

	operation := CFAtelierMove
		object: alpha
		sourceMemento: memento
		sourceDescription: leftItemDescription
		destinationMemento: memento
		destinationDescription: rightItemsDescription
		destinationIndex: 2.
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: leftItemDescription) isNil.
	self assert: (memento readUsing: rightItemsDescription) first == gamma.
	self assert: (memento readUsing: rightItemsDescription) second == alpha.
	self assert: model leftItem == alpha.
	self assert: model rightItems size equals: 1.
	^ assessment
]

{ #category : 'examples - cardinality' }
CFAtelierMoveExamples >> moveFromToManyIntoEmptyToOne [
	<gtExample>
	| model memento alpha beta leftItemsDescription rightItemDescription operation assessment |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	beta := Object new.
	model leftItems: (OrderedCollection with: alpha with: beta).
	memento := CFMaMemento model: model.
	leftItemsDescription := self descriptionFor: #leftItems in: memento.
	rightItemDescription := self descriptionFor: #rightItem in: memento.

	operation := CFAtelierMove
		object: beta
		sourceMemento: memento
		sourceDescription: leftItemsDescription
		destinationMemento: memento
		destinationDescription: rightItemDescription
		destinationIndex: nil.
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: leftItemsDescription) size equals: 1.
	self assert: (memento readUsing: leftItemsDescription) first == alpha.
	self assert: (memento readUsing: rightItemDescription) == beta.
	self assert: model leftItems second == beta.
	self assert: model rightItem isNil.
	^ assessment
]

{ #category : 'examples - cardinality' }
CFAtelierMoveExamples >> occupiedToOneDestinationRejectsMove [
	<gtExample>
	| model memento alpha beta leftItemsDescription rightItemDescription operation assessment |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	beta := Object new.
	model
		leftItems: (OrderedCollection with: alpha);
		rightItem: beta.
	memento := CFMaMemento model: model.
	leftItemsDescription := self descriptionFor: #leftItems in: memento.
	rightItemDescription := self descriptionFor: #rightItem in: memento.

	operation := CFAtelierMove
		object: alpha
		sourceMemento: memento
		sourceDescription: leftItemsDescription
		destinationMemento: memento
		destinationDescription: rightItemDescription
		destinationIndex: nil.
	assessment := operation apply.

	self assert: assessment isApplicable not.
	self assert: assessment rejectionMessage equals: 'A to-one destination must be empty for a move.'.
	self assert: (memento readUsing: leftItemsDescription) first == alpha.
	self assert: (memento readUsing: rightItemDescription) == beta.
	^ assessment
]

{ #category : 'examples - cardinality' }
CFAtelierMoveExamples >> moveBetweenToOneRelations [
	<gtExample>
	| model memento alpha leftItemDescription rightItemDescription operation assessment |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	model leftItem: alpha.
	memento := CFMaMemento model: model.
	leftItemDescription := self descriptionFor: #leftItem in: memento.
	rightItemDescription := self descriptionFor: #rightItem in: memento.

	operation := CFAtelierMove
		object: alpha
		sourceMemento: memento
		sourceDescription: leftItemDescription
		destinationMemento: memento
		destinationDescription: rightItemDescription
		destinationIndex: nil.
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: leftItemDescription) isNil.
	self assert: (memento readUsing: rightItemDescription) == alpha.
	self assert: model leftItem == alpha.
	self assert: model rightItem isNil.
	^ assessment
]

{ #category : 'examples - multiple' }
CFAtelierMoveExamples >> multiMovePreservesAuthoritativeSourceOrder [
	<gtExample>
	| model memento first second third fourth fifth leftDescription rightDescription operation assessment |
	first := Object new.
	second := Object new.
	third := Object new.
	fourth := Object new.
	fifth := Object new.
	model := CFAtelierMoveExampleModel new
		leftItems: (OrderedCollection with: first with: second with: third with: fourth);
		rightItems: (OrderedCollection with: fifth);
		yourself.
	memento := CFMaMemento model: model.
	leftDescription := self descriptionFor: #leftItems in: memento.
	rightDescription := self descriptionFor: #rightItems in: memento.

	operation := CFAtelierMove
		objects: { third. first }
		sourceMemento: memento
		sourceDescription: leftDescription
		destinationMemento: memento
		destinationDescription: rightDescription
		destinationIndex: 2.
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: leftDescription) size equals: 2.
	self assert: (memento readUsing: leftDescription) first == second.
	self assert: (memento readUsing: leftDescription) second == fourth.
	self assert: (memento readUsing: rightDescription) size equals: 3.
	self assert: (memento readUsing: rightDescription) first == fifth.
	self assert: (memento readUsing: rightDescription) second == first.
	self assert: (memento readUsing: rightDescription) third == third.
	self assert: model leftItems first == first.
	self assert: model rightItems size equals: 1.
	^ assessment
]

{ #category : 'examples - multiple' }
CFAtelierMoveExamples >> multiMoveRejectsDuplicateDraggedIdentity [
	<gtExample>
	| fixture memento beta leftDescription rightDescription operation assessment |
	fixture := self fixture.
	memento := fixture second.
	beta := fixture fourth.
	leftDescription := self descriptionFor: #leftItems in: memento.
	rightDescription := self descriptionFor: #rightItems in: memento.
	operation := CFAtelierMove
		objects: { beta. beta }
		sourceMemento: memento
		sourceDescription: leftDescription
		destinationMemento: memento
		destinationDescription: rightDescription
		destinationIndex: 2.
	assessment := operation apply.

	self assert: assessment isApplicable not.
	self assert: (memento readUsing: leftDescription) size equals: 2.
	self assert: (memento readUsing: rightDescription) size equals: 1.
	^ assessment
]

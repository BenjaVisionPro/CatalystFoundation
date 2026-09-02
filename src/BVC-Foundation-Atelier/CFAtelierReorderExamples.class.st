"I prove generic Atelier reorder semantics independently of presentation drag/drop mechanics."
Class {
	#name : 'CFAtelierReorderExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - assessment' }
CFAtelierReorderExamples >> assessmentDoesNotMutateEditingState [
	<gtExample>
	| model memento alpha beta gamma description operation assessment |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	beta := Object new.
	gamma := Object new.
	model leftItems: (OrderedCollection with: alpha with: beta with: gamma).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	operation := CFAtelierReorder
		object: beta
		memento: memento
		description: description
		to: 3.

	assessment := operation assess.

	self assert: assessment isApplicable.
	self assert: assessment sourceIndex equals: 2.
	self assert: assessment destinationIndex equals: 3.
	self assert: assessment proposedItems first == alpha.
	self assert: assessment proposedItems second == gamma.
	self assert: assessment proposedItems third == beta.
	self assert: (memento readUsing: description) second == beta.
	self assert: model leftItems second == beta.
	^ assessment
]

{ #category : 'examples - transaction' }
CFAtelierReorderExamples >> applyStagesReorderWithoutMutatingModel [
	<gtExample>
	| model memento alpha beta gamma description operation assessment |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	beta := Object new.
	gamma := Object new.
	model leftItems: (OrderedCollection with: alpha with: beta with: gamma).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	operation := CFAtelierReorder
		object: alpha
		memento: memento
		description: description
		to: 3.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) first == beta.
	self assert: (memento readUsing: description) second == gamma.
	self assert: (memento readUsing: description) third == alpha.
	self assert: model leftItems first == alpha.
	self assert: model leftItems second == beta.
	self assert: model leftItems third == gamma.
	^ memento
]

{ #category : 'examples - transaction' }
CFAtelierReorderExamples >> commitPreservesEveryObjectIdentity [
	<gtExample>
	| model memento alpha beta gamma description operation |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	beta := Object new.
	gamma := Object new.
	model leftItems: (OrderedCollection with: alpha with: beta with: gamma).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	operation := CFAtelierReorder
		object: gamma
		memento: memento
		description: description
		to: 1.

	self assert: operation apply isApplicable.
	memento commit.

	self assert: model leftItems first == gamma.
	self assert: model leftItems second == alpha.
	self assert: model leftItems third == beta.
	^ model
]

{ #category : 'examples - assessment' }
CFAtelierReorderExamples >> duplicateIdentityIsRejected [
	<gtExample>
	| model memento duplicate other description operation assessment |
	model := CFAtelierMoveExampleModel new.
	duplicate := Object new.
	other := Object new.
	model leftItems: (OrderedCollection with: duplicate with: other with: duplicate).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	operation := CFAtelierReorder
		object: duplicate
		memento: memento
		description: description
		to: 1.

	assessment := operation apply.

	self assert: assessment isApplicable not.
	self assert: assessment rejectionMessage equals: 'The reordered object must occur exactly once in the relation.'.
	self assert: (memento readUsing: description) size equals: 3.
	self assert: model leftItems size equals: 3.
	^ assessment
]

{ #category : 'examples - transaction' }
CFAtelierReorderExamples >> applyReassessesCurrentStagedState [
	<gtExample>
	| model memento alpha beta gamma description operation hoverAssessment applyAssessment |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	beta := Object new.
	gamma := Object new.
	model leftItems: (OrderedCollection with: alpha with: beta with: gamma).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	operation := CFAtelierReorder
		object: beta
		memento: memento
		description: description
		to: 3.

	hoverAssessment := operation assess.
	self assert: hoverAssessment isApplicable.
	memento
		write: (OrderedCollection with: alpha with: gamma)
		using: description.

	applyAssessment := operation apply.

	self assert: applyAssessment isApplicable not.
	self assert: applyAssessment rejectionMessage equals: 'The reordered object must occur exactly once in the relation.'.
	self assert: (memento readUsing: description) size equals: 2.
	self assert: (memento readUsing: description) first == alpha.
	self assert: (memento readUsing: description) second == gamma.
	self assert: model leftItems size equals: 3.
	^ applyAssessment
]

{ #category : 'private' }
CFAtelierReorderExamples >> descriptionFor: aSelector in: aMemento [
	^ aMemento magritteDescription
		detect: [ :each | each handlesSelector: aSelector ]
]

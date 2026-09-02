"I prove generic Atelier insertion independently of any BPM/client-specific creation semantics."
Class {
	#name : 'CFAtelierInsertExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - assessment' }
CFAtelierInsertExamples >> assessmentDoesNotMutateEditingState [
	<gtExample>
	| model memento alpha beta candidate description operation assessment |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	beta := Object new.
	candidate := Object new.
	model leftItems: (OrderedCollection with: alpha with: beta).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	operation := CFAtelierInsert
		object: candidate
		memento: memento
		description: description
		at: 2.

	assessment := operation assess.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) size equals: 2.
	self assert: model leftItems size equals: 2.
	self assert: assessment proposedItems size equals: 3.
	self assert: assessment proposedItems first == alpha.
	self assert: assessment proposedItems second == candidate.
	self assert: assessment proposedItems third == beta.
	^ assessment
]

{ #category : 'examples - transaction' }
CFAtelierInsertExamples >> applyStagesInsertionWithoutMutatingModel [
	<gtExample>
	| model memento alpha candidate description operation assessment |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	candidate := Object new.
	model leftItems: (OrderedCollection with: alpha).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	operation := CFAtelierInsert
		object: candidate
		memento: memento
		description: description
		at: 2.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) size equals: 2.
	self assert: (memento readUsing: description) second == candidate.
	self assert: model leftItems size equals: 1.
	self assert: model leftItems first == alpha.
	^ memento
]

{ #category : 'examples - transaction' }
CFAtelierInsertExamples >> commitPreservesInsertedIdentity [
	<gtExample>
	| model memento candidate description operation |
	model := CFAtelierMoveExampleModel new.
	candidate := Object new.
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	operation := CFAtelierInsert
		object: candidate
		memento: memento
		description: description
		at: 1.

	self assert: operation apply isApplicable.
	memento commit.

	self assert: model leftItems size equals: 1.
	self assert: model leftItems first == candidate.
	^ model
]

{ #category : 'examples - assessment' }
CFAtelierInsertExamples >> validationRejectsWithoutMutation [
	<gtExample>
	| model memento existing candidate description operation assessment |
	model := CFAtelierMoveExampleModel new.
	existing := Object new.
	candidate := Object new.
	model
		rightItems: (OrderedCollection with: existing);
		rightItemLimit: 1.
	memento := CFMaMemento model: model.
	description := self descriptionFor: #rightItems in: memento.
	operation := CFAtelierInsert
		object: candidate
		memento: memento
		description: description
		at: 2.

	assessment := operation apply.

	self assert: assessment isApplicable not.
	self assert: assessment rejectionMessage equals: 'Right: The right relation has reached its configured limit.'.
	self assert: (memento readUsing: description) size equals: 1.
	self assert: model rightItems size equals: 1.
	^ assessment
]

{ #category : 'examples - transaction' }
CFAtelierInsertExamples >> applyReassessesCurrentStagedState [
	<gtExample>
	| model memento existing candidate other description operation hoverAssessment applyAssessment |
	model := CFAtelierMoveExampleModel new.
	existing := Object new.
	candidate := Object new.
	other := Object new.
	model
		rightItems: (OrderedCollection with: existing);
		rightItemLimit: 2.
	memento := CFMaMemento model: model.
	description := self descriptionFor: #rightItems in: memento.
	operation := CFAtelierInsert
		object: candidate
		memento: memento
		description: description
		at: 2.

	hoverAssessment := operation assess.
	self assert: hoverAssessment isApplicable.
	memento
		write: (OrderedCollection with: existing with: other)
		using: description.

	applyAssessment := operation apply.

	self assert: applyAssessment isApplicable not.
	self assert: (memento readUsing: description) size equals: 2.
	self assert: (memento readUsing: description) second == other.
	self assert: model rightItems size equals: 1.
	^ applyAssessment
]

{ #category : 'private' }
CFAtelierInsertExamples >> descriptionFor: aSelector in: aMemento [
	^ aMemento magritteDescription
		detect: [ :each | each handlesSelector: aSelector ]
]

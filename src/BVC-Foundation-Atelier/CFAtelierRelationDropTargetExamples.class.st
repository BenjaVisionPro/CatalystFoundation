"I prove the semantic boundary used by Atelier's first palette-to-relation drop target without depending on pointer-event construction."
Class {
	#name : 'CFAtelierRelationDropTargetExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - relation drop target' }
CFAtelierRelationDropTargetExamples >> assessmentBeforeTargetDoesNotMutateEditingState [
	<gtExample>
	| model memento alpha beta candidate description target assessment |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	beta := Object new.
	candidate := Object new.
	model leftItems: (OrderedCollection with: alpha with: beta).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	target := CFAtelierRelationDropTarget
		targetObject: beta
		memento: memento
		description: description.

	assessment := target assessmentForCandidate: candidate after: false.

	self assert: assessment isApplicable.
	self assert: assessment insertionIndex equals: 2.
	self assert: (memento readUsing: description) size equals: 2.
	self assert: model leftItems size equals: 2.
	^ assessment
]

{ #category : 'examples - relation drop target' }
CFAtelierRelationDropTargetExamples >> applyAfterTargetStagesExactCandidateIdentity [
	<gtExample>
	| model memento alpha candidate description target assessment |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	candidate := Object new.
	model leftItems: (OrderedCollection with: alpha).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	target := CFAtelierRelationDropTarget
		targetObject: alpha
		memento: memento
		description: description.

	assessment := target applyCandidate: candidate after: true.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) size equals: 2.
	self assert: (memento readUsing: description) second == candidate.
	self assert: model leftItems size equals: 1.
	^ assessment
]

{ #category : 'examples - relation drop target' }
CFAtelierRelationDropTargetExamples >> staleTargetIsRejectedBeforeMutation [
	<gtExample>
	| model memento alpha beta candidate description target assessment |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	beta := Object new.
	candidate := Object new.
	model leftItems: (OrderedCollection with: alpha with: beta).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	target := CFAtelierRelationDropTarget
		targetObject: beta
		memento: memento
		description: description.
	memento write: (OrderedCollection with: alpha) using: description.

	assessment := target applyCandidate: candidate after: false.

	self assert: assessment isApplicable not.
	self assert: (memento readUsing: description) size equals: 1.
	self assert: (memento readUsing: description) first == alpha.
	self assert: model leftItems size equals: 2.
	^ assessment
]

{ #category : 'private' }
CFAtelierRelationDropTargetExamples >> descriptionFor: aSelector in: aMemento [
	^ aMemento magritteDescription
		detect: [ :each | each handlesSelector: aSelector ]
]

"I prove the relation-level Atelier insertion surface used when an ordered to-many relation has no item rows."
Class {
	#name : 'CFAtelierRelationDropSurfaceExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - assessment' }
CFAtelierRelationDropSurfaceExamples >> emptyRelationAssessmentDoesNotMutateEditingState [
	<gtExample>
	| model memento candidate description surface assessment |
	model := CFAtelierMoveExampleModel new.
	candidate := Object new.
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	surface := CFAtelierRelationDropSurface memento: memento description: description.

	assessment := surface assessmentForCandidate: candidate.

	self assert: assessment isApplicable.
	self assert: assessment insertionIndex equals: 1.
	self assert: (memento readUsing: description) isEmpty.
	self assert: model leftItems isEmpty.
	^ assessment
]

{ #category : 'examples - transaction' }
CFAtelierRelationDropSurfaceExamples >> emptyRelationDropStagesExactCandidateIdentity [
	<gtExample>
	| model memento candidate description surface assessment |
	model := CFAtelierMoveExampleModel new.
	candidate := Object new.
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	surface := CFAtelierRelationDropSurface memento: memento description: description.

	assessment := surface applyCandidate: candidate.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) size equals: 1.
	self assert: (memento readUsing: description) first == candidate.
	self assert: model leftItems isEmpty.
	^ memento
]

{ #category : 'examples - assessment' }
CFAtelierRelationDropSurfaceExamples >> populatedRelationDefersToItemInsertionTargets [
	<gtExample>
	| model memento existing candidate description surface assessment |
	model := CFAtelierMoveExampleModel new.
	existing := Object new.
	candidate := Object new.
	model leftItems: (OrderedCollection with: existing).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	surface := CFAtelierRelationDropSurface memento: memento description: description.

	assessment := surface assessmentForCandidate: candidate.

	self assert: assessment isApplicable not.
	self assert: (memento readUsing: description) size equals: 1.
	self assert: (memento readUsing: description) first == existing.
	^ assessment
]

{ #category : 'private' }
CFAtelierRelationDropSurfaceExamples >> descriptionFor: aSelector in: aMemento [
	^ aMemento magritteDescription detect: [ :each | each handlesSelector: aSelector ]
]

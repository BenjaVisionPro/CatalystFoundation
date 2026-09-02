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

{ #category : 'examples - relation move' }
CFAtelierRelationDropSurfaceExamples >> existingObjectDragMovesIntoEmptyRelation [
	<gtExample>
	| model memento moved sourceDescription destinationDescription surface sourceElement dragItem operation assessment |
	model := CFAtelierMoveExampleModel new.
	moved := Object new.
	model leftItems: (OrderedCollection with: moved).
	memento := CFMaMemento model: model.
	sourceDescription := self descriptionFor: #leftItems in: memento.
	destinationDescription := self descriptionFor: #rightItems in: memento.
	sourceElement := BlElement new.
	sourceElement userData
		at: #atelierRelationDragContext
		put: (CFAtelierRelationDragContext memento: memento description: sourceDescription).
	dragItem := BlDragItem new sourceElement: sourceElement; domainObject: moved; yourself.
	surface := CFAtelierRelationDropSurface memento: memento description: destinationDescription.
	operation := surface moveOperationForDragItem: dragItem.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: sourceDescription) isEmpty.
	self assert: (memento readUsing: destinationDescription) first == moved.
	self assert: model leftItems first == moved.
	self assert: model rightItems isEmpty.
	^ assessment
]

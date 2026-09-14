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

{ #category : 'examples - relation move' }
CFAtelierRelationDropTargetExamples >> existingObjectDragAssessesCrossRelationMoveWithoutMutation [
	<gtExample>
	| model memento moved targetObject sourceDescription destinationDescription target sourceElement dragItem assessment |
	model := CFAtelierMoveExampleModel new.
	moved := Object new.
	targetObject := Object new.
	model leftItems: (OrderedCollection with: moved).
	model rightItems: (OrderedCollection with: targetObject).
	memento := CFMaMemento model: model.
	sourceDescription := self descriptionFor: #leftItems in: memento.
	destinationDescription := self descriptionFor: #rightItems in: memento.
	sourceElement := BlElement new.
	sourceElement userData
		at: #atelierRelationDragContext
		put: (CFAtelierRelationDragContext memento: memento description: sourceDescription).
	dragItem := BlDragItem new sourceElement: sourceElement; domainObject: moved; yourself.
	target := CFAtelierRelationDropTarget targetObject: targetObject memento: memento description: destinationDescription.

	assessment := target moveAssessmentForDragItem: dragItem after: false.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: sourceDescription) size equals: 1.
	self assert: (memento readUsing: destinationDescription) size equals: 1.
	^ assessment
]

{ #category : 'examples - relation move' }
CFAtelierRelationDropTargetExamples >> existingObjectDragMovesBetweenStagedRelationsAtTargetPosition [
	<gtExample>
	| model memento moved targetObject sourceDescription destinationDescription target sourceElement dragItem operation assessment |
	model := CFAtelierMoveExampleModel new.
	moved := Object new.
	targetObject := Object new.
	model leftItems: (OrderedCollection with: moved).
	model rightItems: (OrderedCollection with: targetObject).
	memento := CFMaMemento model: model.
	sourceDescription := self descriptionFor: #leftItems in: memento.
	destinationDescription := self descriptionFor: #rightItems in: memento.
	sourceElement := BlElement new.
	sourceElement userData
		at: #atelierRelationDragContext
		put: (CFAtelierRelationDragContext memento: memento description: sourceDescription).
	dragItem := BlDragItem new sourceElement: sourceElement; domainObject: moved; yourself.
	target := CFAtelierRelationDropTarget targetObject: targetObject memento: memento description: destinationDescription.
	operation := target moveOperationForDragItem: dragItem after: true.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: sourceDescription) isEmpty.
	self assert: (memento readUsing: destinationDescription) second == moved.
	self assert: model leftItems first == moved.
	self assert: model rightItems first == targetObject.
	^ assessment
]

{ #category : 'examples - relation move' }
CFAtelierRelationDropTargetExamples >> existingObjectDragWithinSameRelationDefersToFoundationReorder [
	<gtExample>
	| model memento moved targetObject description target sourceElement dragItem assessment |
	model := CFAtelierMoveExampleModel new.
	moved := Object new.
	targetObject := Object new.
	model leftItems: (OrderedCollection with: moved with: targetObject).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	sourceElement := BlElement new.
	sourceElement userData
		at: #atelierRelationDragContext
		put: (CFAtelierRelationDragContext memento: memento description: description).
	dragItem := BlDragItem new sourceElement: sourceElement; domainObject: moved; yourself.
	target := CFAtelierRelationDropTarget targetObject: targetObject memento: memento description: description.

	assessment := target moveAssessmentForDragItem: dragItem after: true.

	self assert: assessment isApplicable not.
	self assert: (memento readUsing: description) first == moved.
	^ assessment
]


{ #category : 'examples - relation replacement' }
CFAtelierRelationDropTargetExamples >> paletteCandidateAssessesReplacementWithoutMutation [
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

	assessment := target replacementAssessmentForCandidate: candidate.

	self assert: assessment isApplicable.
	self assert: assessment replacementIndex equals: 2.
	self assert: (memento readUsing: description) second == beta.
	self assert: model leftItems second == beta.
	^ assessment
]

{ #category : 'examples - relation replacement' }
CFAtelierRelationDropTargetExamples >> paletteCandidateReplacementStagesExactIdentityAtTargetPosition [
	<gtExample>
	| model memento alpha beta candidate description target assessment stagedItems |
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

	assessment := target applyReplacementCandidate: candidate.
	stagedItems := memento readUsing: description.

	self assert: assessment isApplicable.
	self assert: stagedItems size equals: 2.
	self assert: stagedItems first == alpha.
	self assert: stagedItems second == candidate.
	self assert: model leftItems second == beta.
	^ assessment
]

{ #category : 'examples - relation replacement' }
CFAtelierRelationDropTargetExamples >> staleTargetRejectsPaletteReplacement [
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

	assessment := target applyReplacementCandidate: candidate.

	self assert: assessment isApplicable not.
	self assert: (memento readUsing: description) size equals: 1.
	self assert: (memento readUsing: description) first == alpha.
	self assert: model leftItems second == beta.
	^ assessment
]

{ #category : 'examples - relation move' }
CFAtelierRelationDropTargetExamples >> multiObjectDragBuildsOneMoveInSourceRelationOrder [
	<gtExample>
	| model memento first second third targetObject sourceDescription destinationDescription target sourceElement dragItem operation assessment |
	first := Object new.
	second := Object new.
	third := Object new.
	targetObject := Object new.
	model := CFAtelierMoveExampleModel new
		leftItems: (OrderedCollection with: first with: second with: third);
		rightItems: (OrderedCollection with: targetObject);
		yourself.
	memento := CFMaMemento model: model.
	sourceDescription := self descriptionFor: #leftItems in: memento.
	destinationDescription := self descriptionFor: #rightItems in: memento.
	sourceElement := BlElement new.
	sourceElement userData
		at: #atelierRelationDragContext
		put: (CFAtelierRelationDragContext memento: memento description: sourceDescription).
	dragItem := BlDragItem new sourceElement: sourceElement; domainObject: third; yourself.
	target := CFAtelierRelationDropTarget targetObject: targetObject memento: memento description: destinationDescription.

	operation := target
		moveOperationForObjects: { third. first }
		sourceDragItem: dragItem
		after: true.
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: sourceDescription) size equals: 1.
	self assert: (memento readUsing: sourceDescription) first == second.
	self assert: (memento readUsing: destinationDescription) size equals: 3.
	self assert: (memento readUsing: destinationDescription) first == targetObject.
	self assert: (memento readUsing: destinationDescription) second == first.
	self assert: (memento readUsing: destinationDescription) third == third.
	^ assessment
]

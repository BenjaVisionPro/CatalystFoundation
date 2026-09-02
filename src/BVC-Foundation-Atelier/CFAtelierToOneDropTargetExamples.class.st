"I prove Atelier palette replacement semantics for to-one relation drop targets without depending on pointer interaction."
Class {
	#name : 'CFAtelierToOneDropTargetExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - assessment' }
CFAtelierToOneDropTargetExamples >> occupiedRelationAssessmentDoesNotMutateEditingState [
	<gtExample>
	| model existing candidate memento description target assessment |
	model := CFAtelierReplaceExampleModel new.
	existing := Object new.
	candidate := Object new.
	model primaryItem: existing.
	memento := CFMaMemento model: model.
	description := self descriptionFor: #primaryItem in: memento.
	target := CFAtelierToOneDropTarget memento: memento description: description.

	assessment := target assessmentForCandidate: candidate.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) == existing.
	self assert: model primaryItem == existing.
	^ assessment
]

{ #category : 'examples - transaction' }
CFAtelierToOneDropTargetExamples >> occupiedRelationDropStagesReplacementIdentity [
	<gtExample>
	| model existing candidate memento description target assessment |
	model := CFAtelierReplaceExampleModel new.
	existing := Object new.
	candidate := Object new.
	model primaryItem: existing.
	memento := CFMaMemento model: model.
	description := self descriptionFor: #primaryItem in: memento.
	target := CFAtelierToOneDropTarget memento: memento description: description.

	assessment := target applyCandidate: candidate.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) == candidate.
	self assert: model primaryItem == existing.
	^ memento
]

{ #category : 'examples - transaction' }
CFAtelierToOneDropTargetExamples >> emptyRelationDropStagesCandidateIdentity [
	<gtExample>
	| model candidate memento description target assessment |
	model := CFAtelierReplaceExampleModel new.
	candidate := Object new.
	memento := CFMaMemento model: model.
	description := self descriptionFor: #primaryItem in: memento.
	target := CFAtelierToOneDropTarget memento: memento description: description.

	assessment := target applyCandidate: candidate.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) == candidate.
	self assert: model primaryItem isNil.
	^ memento
]

{ #category : 'examples - assessment' }
CFAtelierToOneDropTargetExamples >> sameIdentityIsRejected [
	<gtExample>
	| model existing memento description target assessment |
	model := CFAtelierReplaceExampleModel new.
	existing := Object new.
	model primaryItem: existing.
	memento := CFMaMemento model: model.
	description := self descriptionFor: #primaryItem in: memento.
	target := CFAtelierToOneDropTarget memento: memento description: description.

	assessment := target assessmentForCandidate: existing.

	self assert: assessment isApplicable not.
	self assert: (memento readUsing: description) == existing.
	^ assessment
]

{ #category : 'private' }
CFAtelierToOneDropTargetExamples >> descriptionFor: aSelector in: aMemento [
	^ aMemento magritteDescription detect: [ :each | each handlesSelector: aSelector ]
]

{ #category : 'examples - move' }
CFAtelierToOneDropTargetExamples >> relationDragMovesIntoEmptyToOne [
	<gtExample>
	| model memento alpha sourceDescription destinationDescription sourceElement dragItem target assessment |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	model leftItems: (OrderedCollection with: alpha).
	memento := CFMaMemento model: model.
	sourceDescription := memento magritteDescription detect: [ :each | each handlesSelector: #leftItems ].
	destinationDescription := memento magritteDescription detect: [ :each | each handlesSelector: #rightItem ].
	sourceElement := BlElement new.
	sourceElement userData
		at: #atelierRelationDragContext
		put: (CFAtelierRelationDragContext memento: memento description: sourceDescription).
	dragItem := BlDragItem new
		sourceElement: sourceElement;
		domainObject: alpha;
		yourself.
	target := CFAtelierToOneDropTarget
		memento: memento
		description: destinationDescription.

	assessment := target moveAssessmentForDragItem: dragItem.
	self assert: assessment isApplicable.
	self assert: (memento readUsing: sourceDescription) first == alpha.
	self assert: (memento readUsing: destinationDescription) isNil.
	self assert: (target moveOperationForDragItem: dragItem) apply isApplicable.
	self assert: (memento readUsing: sourceDescription) isEmpty.
	self assert: (memento readUsing: destinationDescription) == alpha.
	^ assessment
]

{ #category : 'examples - drag source' }
CFAtelierToOneDropTargetExamples >> toOneDragPreservesExistingIdentityAndSourceContext [
	<gtExample>
	| model memento alpha description element target dragItems dragItem context |
	model := CFAtelierMoveExampleModel new.
	alpha := Object new.
	model leftItem: alpha.
	memento := CFMaMemento model: model.
	description := memento magritteDescription detect: [ :each | each handlesSelector: #leftItem ].
	element := BlElement new.
	target := CFAtelierToOneDropTarget new
		element: element;
		memento: memento;
		description: description;
		yourself.
	target installSourceContext.
	dragItems := target dragItemsFrom: element.
	dragItem := dragItems first.
	context := element userData at: #atelierRelationDragContext.

	self assert: dragItems size equals: 1.
	self assert: dragItem domainObject == alpha.
	self assert: context memento == memento.
	self assert: context description == description.
	^ dragItem
]

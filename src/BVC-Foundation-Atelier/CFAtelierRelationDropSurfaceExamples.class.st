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

{ #category : 'examples - unordered relation' }
CFAtelierRelationDropSurfaceExamples >> populatedUnorderedRelationAcceptsPaletteInsertion [
	<gtExample>
	| model memento existing candidate description surface assessment |
	model := CFAtelierMoveExampleModel new.
	existing := Object new.
	candidate := Object new.
	model looseItems: (OrderedCollection with: existing).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #looseItems in: memento.
	surface := CFAtelierRelationDropSurface memento: memento description: description.

	assessment := surface applyCandidate: candidate.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) size equals: 2.
	self assert: (memento readUsing: description) first == existing.
	self assert: (memento readUsing: description) second == candidate.
	self assert: model looseItems size equals: 1.
	^ assessment
]

{ #category : 'examples - unordered relation' }
CFAtelierRelationDropSurfaceExamples >> existingObjectDragMovesIntoPopulatedUnorderedRelation [
	<gtExample>
	| model memento moved existing sourceDescription destinationDescription surface sourceElement dragItem operation assessment |
	model := CFAtelierMoveExampleModel new.
	moved := Object new.
	existing := Object new.
	model leftItems: (OrderedCollection with: moved).
	model looseItems: (OrderedCollection with: existing).
	memento := CFMaMemento model: model.
	sourceDescription := self descriptionFor: #leftItems in: memento.
	destinationDescription := self descriptionFor: #looseItems in: memento.
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
	self assert: (memento readUsing: destinationDescription) size equals: 2.
	self assert: (memento readUsing: destinationDescription) first == existing.
	self assert: (memento readUsing: destinationDescription) second == moved.
	self assert: model leftItems first == moved.
	self assert: model looseItems first == existing.
	^ assessment
]

{ #category : 'examples - configured operation' }
CFAtelierRelationDropSurfaceExamples >> configuredInsertOperationReceivesExactDestinationContext [
	<gtExample>
	| model memento candidate description surface receivedCandidate receivedMemento receivedDescription receivedIndex assessment |
	model := CFAtelierMoveExampleModel new.
	candidate := Object new.
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	surface := CFAtelierRelationDropSurface memento: memento description: description.
	surface insertOperationFor: [ :anObject :aMemento :aDescription :anIndex |
		receivedCandidate := anObject.
		receivedMemento := aMemento.
		receivedDescription := aDescription.
		receivedIndex := anIndex.
		CFAtelierInsert object: anObject memento: aMemento description: aDescription at: anIndex ].

	assessment := surface assessmentForCandidate: candidate.

	self assert: assessment isApplicable.
	self assert: receivedCandidate == candidate.
	self assert: receivedMemento == memento.
	self assert: receivedDescription == description.
	self assert: receivedIndex equals: 1.
	self assert: (memento readUsing: description) isEmpty.
	^ assessment
]


{ #category : 'examples - configured operation' }
CFAtelierRelationDropSurfaceExamples >> configuredMoveOperationReceivesExactSourceAndDestinationContexts [
	<gtExample>
	| model memento moved sourceDescription destinationDescription surface sourceElement dragItem receivedObject receivedSourceContext receivedDestinationContext receivedIndex assessment |
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
	surface moveOperationFor: [ :anObject :aSourceContext :aDestinationContext :anIndex |
		receivedObject := anObject.
		receivedSourceContext := aSourceContext.
		receivedDestinationContext := aDestinationContext.
		receivedIndex := anIndex.
		CFAtelierMove
			object: anObject
			sourceMemento: aSourceContext memento
			sourceDescription: aSourceContext description
			destinationMemento: aDestinationContext memento
			destinationDescription: aDestinationContext description
			destinationIndex: anIndex ].

	assessment := (surface moveOperationForDragItem: dragItem) assess.

	self assert: assessment isApplicable.
	self assert: receivedObject == moved.
	self assert: receivedSourceContext memento == memento.
	self assert: receivedSourceContext description == sourceDescription.
	self assert: receivedDestinationContext memento == memento.
	self assert: receivedDestinationContext description == destinationDescription.
	self assert: receivedIndex equals: 1.
	self assert: (memento readUsing: sourceDescription) first == moved.
	self assert: (memento readUsing: destinationDescription) isEmpty.
	^ assessment
]

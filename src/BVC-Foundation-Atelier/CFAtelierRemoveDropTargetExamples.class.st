"I prove that the Atelier remove drop surface delegates removal to CFAtelierRemove without inventing another deletion mechanism."
Class {
	#name : 'CFAtelierRemoveDropTargetExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - remove UI' }
CFAtelierRemoveDropTargetExamples >> relationDragAssessmentDoesNotMutate [
	<gtExample>
	| model memento object description dragItem target assessment |
	model := CFAtelierMoveExampleModel new.
	object := Object new.
	model leftItems: (OrderedCollection with: object).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	dragItem := self dragItemFor: object memento: memento description: description.
	target := CFAtelierRemoveDropTarget new.

	assessment := target assessmentForDragItem: dragItem.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) first == object.
	self assert: model leftItems first == object.
	^ target
]

{ #category : 'examples - remove UI' }
CFAtelierRemoveDropTargetExamples >> relationDragStagesRemoval [
	<gtExample>
	| model memento object remaining description dragItem target assessment |
	model := CFAtelierMoveExampleModel new.
	object := Object new.
	remaining := Object new.
	model leftItems: (OrderedCollection with: object with: remaining).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	dragItem := self dragItemFor: object memento: memento description: description.
	target := CFAtelierRemoveDropTarget new.

	assessment := target applyDragItem: dragItem.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) size equals: 1.
	self assert: (memento readUsing: description) first == remaining.
	self assert: model leftItems first == object.
	^ target
]

{ #category : 'examples - remove UI' }
CFAtelierRemoveDropTargetExamples >> staleRelationDragIsRejected [
	<gtExample>
	| model memento object description dragItem target assessment |
	model := CFAtelierMoveExampleModel new.
	object := Object new.
	model leftItems: (OrderedCollection with: object).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	dragItem := self dragItemFor: object memento: memento description: description.
	target := CFAtelierRemoveDropTarget new.
	memento write: OrderedCollection new using: description.

	assessment := target assessmentForDragItem: dragItem.

	self assert: assessment isApplicable not.
	self assert: (target acceptsDragItem: dragItem) not.
	^ target
]

{ #category : 'private' }
CFAtelierRemoveDropTargetExamples >> dragItemFor: anObject memento: aMemento description: aDescription [
	| aSourceElement |
	aSourceElement := BlElement new.
	aSourceElement userData
		at: #atelierRelationDragContext
		put: (CFAtelierRelationDragContext memento: aMemento description: aDescription).
	^ BlDragItem new
		sourceElement: aSourceElement;
		domainObject: anObject;
		yourself
]

{ #category : 'private' }
CFAtelierRemoveDropTargetExamples >> descriptionFor: aSelector in: aMemento [
	^ aMemento magritteDescription detect: [ :each | each handlesSelector: aSelector ]
]

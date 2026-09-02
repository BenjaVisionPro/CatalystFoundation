"I prove Atelier's generic single-relation removal semantics."
Class {
	#name : 'CFAtelierRemoveExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'private' }
CFAtelierRemoveExamples >> descriptionFor: aSelector in: aMemento [
	^ aMemento magritteDescription detect: [ :each | each handlesSelector: aSelector ]
]

{ #category : 'examples - to many' }
CFAtelierRemoveExamples >> assessmentDoesNotMutateToManyRelation [
	<gtExample>
	| model first second memento description assessment |
	model := CFAtelierMoveExampleModel new.
	first := Object new. second := Object new.
	model leftItems: (OrderedCollection with: first with: second).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	assessment := (CFAtelierRemove object: first memento: memento description: description) assess.
	self assert: assessment isApplicable.
	self assert: assessment proposedValue size equals: 1.
	self assert: assessment proposedValue first == second.
	self assert: (memento readUsing: description) first == first.
	self assert: model leftItems first == first.
	^ assessment
]

{ #category : 'examples - to many' }
CFAtelierRemoveExamples >> applyStagesToManyRemovalAndCommitPreservesRemainingIdentity [
	<gtExample>
	| model first second memento description assessment |
	model := CFAtelierMoveExampleModel new.
	first := Object new. second := Object new.
	model leftItems: (OrderedCollection with: first with: second).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	assessment := (CFAtelierRemove object: first memento: memento description: description) apply.
	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) size equals: 1.
	self assert: (memento readUsing: description) first == second.
	self assert: model leftItems size equals: 2.
	memento commit.
	self assert: model leftItems size equals: 1.
	self assert: model leftItems first == second.
	^ model
]

{ #category : 'examples - to one' }
CFAtelierRemoveExamples >> applyStagesToOneClear [
	<gtExample>
	| model source replacement memento description assessment |
	model := CFAtelierReplaceExampleModel new.
	source := Object new. replacement := Object new.
	model singleItem: source.
	memento := CFMaMemento model: model.
	description := self descriptionFor: #singleItem in: memento.
	assessment := (CFAtelierRemove object: source memento: memento description: description) apply.
	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) isNil.
	self assert: model singleItem == source.
	^ assessment
]

{ #category : 'examples - reassessment' }
CFAtelierRemoveExamples >> staleObjectIsRejectedOnApply [
	<gtExample>
	| model source other memento description operation assessment |
	model := CFAtelierMoveExampleModel new.
	source := Object new. other := Object new.
	model leftItems: (OrderedCollection with: source).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	operation := CFAtelierRemove object: source memento: memento description: description.
	self assert: operation assess isApplicable.
	memento write: (OrderedCollection with: other) using: description.
	assessment := operation apply.
	self assert: assessment isApplicable not.
	self assert: (memento readUsing: description) first == other.
	^ assessment
]

{ #category : 'examples - identity' }
CFAtelierRemoveExamples >> duplicateIdentityIsRejected [
	<gtExample>
	| model object memento description assessment |
	model := CFAtelierMoveExampleModel new.
	object := Object new.
	model leftItems: (OrderedCollection with: object with: object).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	assessment := (CFAtelierRemove object: object memento: memento description: description) assess.
	self assert: assessment isApplicable not.
	self assert: (memento readUsing: description) size equals: 2.
	^ assessment
]

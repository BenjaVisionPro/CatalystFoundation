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
	| model source memento description assessment |
	model := CFAtelierReplaceExampleModel new.
	source := Object new.
	model primaryItem: source.
	memento := CFMaMemento model: model.
	description := self descriptionFor: #primaryItem in: memento.
	assessment := (CFAtelierRemove object: source memento: memento description: description) apply.
	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) isNil.
	self assert: model primaryItem == source.
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

{ #category : 'examples - embedded transaction' }
CFAtelierRemoveExamples >> commitDoesNotCommitDetachedEmbeddedEdits [
	<gtExample>
	| model child parentMemento relationDescription childMemento nameDescription operation |
	model := CFAtelierMoveExampleModel new.
	child := CFAtelierEntryExampleModel new.
	model leftItems: (OrderedCollection with: child).
	parentMemento := CFMaMemento model: model.
	relationDescription := self descriptionFor: #leftItems in: parentMemento.
	childMemento := parentMemento childMementoFor: child inRelation: relationDescription.
	nameDescription := self descriptionFor: #name in: childMemento.
	childMemento write: 'Staged child name' using: nameDescription.

	operation := CFAtelierRemove object: child memento: parentMemento description: relationDescription.
	self assert: operation apply isApplicable.
	parentMemento commit.

	self assert: model leftItems isEmpty.
	self assert: child name equals: 'Atelier example'.
	^ parentMemento
]

{ #category : 'examples - embedded transaction' }
CFAtelierRemoveExamples >> resetRestoresDetachedEmbeddedMementoIdentity [
	<gtExample>
	| model child parentMemento relationDescription childMemento nameDescription operation restoredChildMemento |
	model := CFAtelierMoveExampleModel new.
	child := CFAtelierEntryExampleModel new.
	model leftItems: (OrderedCollection with: child).
	parentMemento := CFMaMemento model: model.
	relationDescription := self descriptionFor: #leftItems in: parentMemento.
	childMemento := parentMemento childMementoFor: child inRelation: relationDescription.
	nameDescription := self descriptionFor: #name in: childMemento.
	childMemento write: 'Staged child name' using: nameDescription.

	operation := CFAtelierRemove object: child memento: parentMemento description: relationDescription.
	self assert: operation apply isApplicable.
	parentMemento reset.
	restoredChildMemento := parentMemento childMementoFor: child inRelation: relationDescription.

	self assert: (parentMemento readUsing: relationDescription) size equals: 1.
	self assert: (parentMemento readUsing: relationDescription) first == child.
	self assert: restoredChildMemento == childMemento.
	self assert: (restoredChildMemento readUsing: nameDescription) equals: 'Atelier example'.
	^ parentMemento
]


{ #category : 'examples - embedded transaction' }
CFAtelierRemoveExamples >> reinsertRestoresDetachedEmbeddedMementoIdentity [
	<gtExample>
	| model child parentMemento relationDescription childMemento nameDescription remove insert reattachedChildMemento |
	model := CFAtelierMoveExampleModel new.
	child := CFAtelierEntryExampleModel new.
	model leftItems: (OrderedCollection with: child).
	parentMemento := CFMaMemento model: model.
	relationDescription := self descriptionFor: #leftItems in: parentMemento.
	childMemento := parentMemento childMementoFor: child inRelation: relationDescription.
	nameDescription := self descriptionFor: #name in: childMemento.
	childMemento write: 'Staged child name' using: nameDescription.

	remove := CFAtelierRemove object: child memento: parentMemento description: relationDescription.
	self assert: remove apply isApplicable.
	insert := CFAtelierInsert object: child memento: parentMemento description: relationDescription at: 1.
	self assert: insert apply isApplicable.
	reattachedChildMemento := parentMemento childMementoFor: child inRelation: relationDescription.

	self assert: reattachedChildMemento == childMemento.
	self assert: (reattachedChildMemento readUsing: nameDescription) equals: 'Staged child name'.
	parentMemento commit.
	self assert: model leftItems first == child.
	self assert: child name equals: 'Staged child name'.
	^ parentMemento
]

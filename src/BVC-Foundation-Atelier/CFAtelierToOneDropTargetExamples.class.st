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

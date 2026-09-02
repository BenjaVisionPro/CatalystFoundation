"I prove Atelier's reference/reuse semantics without introducing a duplicate operation.

A reference is an existing object supplied by CFAtelierExistingObjectProvider and then used as the exact candidate of the ordinary destination edit. To-many reuse is CFAtelierInsert; to-one reuse is CFAtelierReplace. Neither operation clones or removes the source object. The distinction from Copy therefore lives in supply identity, not in a second relation-mutation protocol."
Class {
	#name : 'CFAtelierReferenceExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - reference' }
CFAtelierReferenceExamples >> existingProviderPreservesReferenceIdentity [
	<gtExample>
	| object provider candidate |
	object := Object new.
	provider := CFAtelierExistingObjectProvider object: object.

	candidate := provider materialize.

	self assert: candidate == object.
	^ candidate
]

{ #category : 'examples - reference' }
CFAtelierReferenceExamples >> insertReusesExistingIdentity [
	<gtExample>
	| model referenced memento description provider candidate assessment |
	model := CFAtelierReplaceExampleModel new.
	referenced := Object new.
	provider := CFAtelierExistingObjectProvider object: referenced.
	candidate := provider materialize.
	memento := CFMaMemento model: model.
	description := self itemsDescriptionIn: memento.

	assessment := (CFAtelierInsert
		object: candidate
		memento: memento
		description: description
		at: 1) apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) first == referenced.
	self assert: model items isEmpty.
	^ assessment
]

{ #category : 'examples - reference' }
CFAtelierReferenceExamples >> replaceReusesExistingIdentity [
	<gtExample>
	| model source referenced memento description provider candidate assessment |
	model := CFAtelierReplaceExampleModel new.
	source := Object new.
	referenced := Object new.
	model primaryItem: source.
	provider := CFAtelierExistingObjectProvider object: referenced.
	candidate := provider materialize.
	memento := CFMaMemento model: model.
	description := self primaryItemDescriptionIn: memento.

	assessment := (CFAtelierReplace
		object: source
		with: candidate
		memento: memento
		description: description) apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) == referenced.
	self assert: model primaryItem == source.
	^ assessment
]

{ #category : 'private' }
CFAtelierReferenceExamples >> itemsDescriptionIn: aMemento [
	^ aMemento magritteDescription children
		detect: [ :each | each accessor selector = #items ]
]

{ #category : 'private' }
CFAtelierReferenceExamples >> primaryItemDescriptionIn: aMemento [
	^ aMemento magritteDescription children
		detect: [ :each | each accessor selector = #primaryItem ]
]

"I prove that Foundation-owned delete/backspace relation gestures can be translated through Atelier's remove operation boundary, including a complete multi-selection intention."
Class {
	#name : 'CFAtelierRemoveOperationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - removal integration' }
CFAtelierRemoveOperationExamples >> configuredMultiRemovalReceivesOneCompleteIntention [
	<gtExample>
	| model first second third memento description viewModel captured assessment |
	first := Object new. second := Object new. third := Object new.
	model := CFAtelierMoveExampleModel new
		leftItems: (OrderedCollection with: first with: second with: third);
		yourself.
	memento := CFMaMemento model: model.
	description := memento magritteDescription detect: [ :each | each handlesSelector: #leftItems ].
	captured := nil.
	viewModel := CFAtelierViewModel forObject: model memento: memento.
	viewModel removeOperationFor: [ :someObjects :aContext |
		captured := { someObjects. aContext }.
		CFAtelierRemove
			objects: someObjects
			memento: aContext memento
			description: aContext description ].

	assessment := viewModel
		applyRemoveOf: { first. third }
		memento: memento
		description: description.

	self assert: assessment isApplicable.
	self assert: captured first size equals: 2.
	self assert: captured first first == first.
	self assert: captured first second == third.
	self assert: captured second memento == memento.
	self assert: captured second description == description.
	self assert: (memento readUsing: description) size equals: 1.
	self assert: (memento readUsing: description) first == second.
	self assert: model leftItems size equals: 3.
	^ assessment
]

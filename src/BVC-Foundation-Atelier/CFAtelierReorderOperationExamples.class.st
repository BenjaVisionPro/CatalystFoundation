"I prove that Atelier can translate Foundation Detail's existing single-item reorder gesture through the same operation boundary as its other editing intentions."
Class {
	#name : 'CFAtelierReorderOperationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - reorder integration' }
CFAtelierReorderOperationExamples >> configuredReorderReceivesFinalDestinationIndex [
	<gtExample>
	| model first second third memento description viewModel captured operation assessment |
	first := Object new.
	second := Object new.
	third := Object new.
	model := CFAtelierMoveExampleModel new
		leftItems: (OrderedCollection with: first with: second with: third);
		yourself.
	memento := CFMaMemento model: model.
	description := memento magritteDescription detect: [ :each | each handlesSelector: #leftItems ].
	viewModel := CFAtelierViewModel forObject: model memento: memento.
	viewModel reorderOperationFor: [ :anObject :aMemento :aDescription :anIndex |
		captured := { anObject. aMemento. aDescription. anIndex }.
		CFAtelierReorder object: anObject memento: aMemento description: aDescription to: anIndex ].

	operation := viewModel
		reorderOperationFor: first
		relativeTo: third
		after: true
		memento: memento
		description: description.
	assessment := operation assess.

	self assert: captured first == first.
	self assert: captured second == memento.
	self assert: captured third == description.
	self assert: captured fourth equals: 3.
	self assert: assessment isApplicable.
	self assert: (memento readUsing: description) first == first.
	^ operation
]

{ #category : 'examples - reorder integration' }
CFAtelierReorderOperationExamples >> genericReorderUsesFoundationGestureGeometryAsFinalIndex [
	<gtExample>
	| model first second third memento description viewModel assessment staged |
	first := Object new.
	second := Object new.
	third := Object new.
	model := CFAtelierMoveExampleModel new
		leftItems: (OrderedCollection with: first with: second with: third);
		yourself.
	memento := CFMaMemento model: model.
	description := memento magritteDescription detect: [ :each | each handlesSelector: #leftItems ].
	viewModel := CFAtelierViewModel forObject: model memento: memento.

	assessment := viewModel
		applyReorderOf: third
		relativeTo: first
		after: false
		memento: memento
		description: description.
	staged := memento readUsing: description.

	self assert: assessment isApplicable.
	self assert: staged first == third.
	self assert: staged second == first.
	self assert: staged third == second.
	self assert: model leftItems first == first.
	^ assessment
]

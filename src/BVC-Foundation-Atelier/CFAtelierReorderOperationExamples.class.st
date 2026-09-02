"I prove that Atelier translates Foundation Detail's existing single- and multi-item reorder gestures through the same operation boundary as its other editing intentions."
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
	viewModel reorderOperationFor: [ :someObjects :aMemento :aDescription :anIndex |
		captured := { someObjects. aMemento. aDescription. anIndex }.
		CFAtelierReorder objects: someObjects memento: aMemento description: aDescription to: anIndex ].

	operation := viewModel
		reorderOperationFor: { first }
		relativeTo: third
		after: true
		memento: memento
		description: description.
	assessment := operation assess.

	self assert: captured first size equals: 1.
	self assert: captured first first == first.
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
		applyReorderOf: { third }
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

{ #category : 'examples - reorder integration' }
CFAtelierReorderOperationExamples >> multiSelectionReorderPreservesRelationOrder [
	<gtExample>
	| model first second third fourth fifth memento description viewModel assessment staged |
	first := Object new.
	second := Object new.
	third := Object new.
	fourth := Object new.
	fifth := Object new.
	model := CFAtelierMoveExampleModel new
		leftItems: (OrderedCollection with: first with: second with: third with: fourth with: fifth);
		yourself.
	memento := CFMaMemento model: model.
	description := memento magritteDescription detect: [ :each | each handlesSelector: #leftItems ].
	viewModel := CFAtelierViewModel forObject: model memento: memento.

	assessment := viewModel
		applyReorderOf: { fourth. second }
		relativeTo: fifth
		after: true
		memento: memento
		description: description.
	staged := memento readUsing: description.

	self assert: assessment isApplicable.
	self assert: assessment objects first == second.
	self assert: assessment objects second == fourth.
	self assert: staged first == first.
	self assert: staged second == third.
	self assert: staged third == fifth.
	self assert: staged fourth == second.
	self assert: staged fifth == fourth.
	self assert: model leftItems second == second.
	^ assessment
]

{ #category : 'examples - reorder integration' }
CFAtelierReorderOperationExamples >> configuredMultiSelectionReceivesObjectsInRelationOrder [
	<gtExample>
	| model first second third fourth memento description viewModel captured operation assessment |
	first := Object new.
	second := Object new.
	third := Object new.
	fourth := Object new.
	model := CFAtelierMoveExampleModel new
		leftItems: (OrderedCollection with: first with: second with: third with: fourth);
		yourself.
	memento := CFMaMemento model: model.
	description := memento magritteDescription detect: [ :each | each handlesSelector: #leftItems ].
	viewModel := CFAtelierViewModel forObject: model memento: memento.
	viewModel reorderOperationFor: [ :someObjects :aMemento :aDescription :anIndex |
		captured := { someObjects. aMemento. aDescription. anIndex }.
		CFAtelierReorder objects: someObjects memento: aMemento description: aDescription to: anIndex ].

	operation := viewModel
		reorderOperationFor: { third. first }
		relativeTo: fourth
		after: true
		memento: memento
		description: description.
	assessment := operation assess.

	self assert: captured first first == first.
	self assert: captured first second == third.
	self assert: captured fourth equals: 3.
	self assert: assessment isApplicable.
	^ operation
]

"I prove Atelier's copy intention without prescribing how domain objects are copied."
Class {
	#name : 'CFAtelierCopyExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'private' }
CFAtelierCopyExamples >> fixture [
	| model source copy existing memento |
	model := CFAtelierMoveExampleModel new.
	source := Object new.
	copy := Object new.
	existing := Object new.
	model leftItems: (OrderedCollection with: source).
	model rightItems: (OrderedCollection with: existing).
	memento := CFMaMemento model: model.
	^ { model. memento. source. copy. existing }
]

{ #category : 'private' }
CFAtelierCopyExamples >> descriptionFor: aSelector in: aMemento [
	^ aMemento magritteDescription detect: [ :each | each handlesSelector: aSelector ]
]

{ #category : 'private' }
CFAtelierCopyExamples >> copy: aSource copiedObject: aCopy memento: aMemento at: anIndex [
	^ CFAtelierCopy
		sourceObject: aSource
		copiedObject: aCopy
		sourceMemento: aMemento
		sourceDescription: (self descriptionFor: #leftItems in: aMemento)
		destinationMemento: aMemento
		destinationDescription: (self descriptionFor: #rightItems in: aMemento)
		destinationIndex: anIndex
]

{ #category : 'examples - assessment' }
CFAtelierCopyExamples >> assessmentDoesNotMutateEditingState [
	<gtExample>
	| fixture model memento source copy existing assessment |
	fixture := self fixture.
	model := fixture first. memento := fixture second. source := fixture third. copy := fixture fourth. existing := fixture fifth.
	assessment := (self copy: source copiedObject: copy memento: memento at: 2) assess.
	self assert: assessment isApplicable.
	self assert: (memento readUsing: (self descriptionFor: #leftItems in: memento)) first == source.
	self assert: (memento readUsing: (self descriptionFor: #rightItems in: memento)) first == existing.
	self assert: model leftItems first == source.
	self assert: model rightItems first == existing.
	self assert: assessment proposedDestinationItems second == copy.
	^ assessment
]

{ #category : 'examples - transaction' }
CFAtelierCopyExamples >> applyStagesCopyAndLeavesSource [
	<gtExample>
	| fixture model memento source copy existing assessment leftDescription rightDescription |
	fixture := self fixture.
	model := fixture first. memento := fixture second. source := fixture third. copy := fixture fourth. existing := fixture fifth.
	leftDescription := self descriptionFor: #leftItems in: memento.
	rightDescription := self descriptionFor: #rightItems in: memento.
	assessment := (self copy: source copiedObject: copy memento: memento at: 2) apply.
	self assert: assessment isApplicable.
	self assert: (memento readUsing: leftDescription) first == source.
	self assert: (memento readUsing: rightDescription) first == existing.
	self assert: (memento readUsing: rightDescription) second == copy.
	self assert: model rightItems size equals: 1.
	^ memento
]

{ #category : 'examples - transaction' }
CFAtelierCopyExamples >> commitPreservesSourceAndUsesCopyIdentity [
	<gtExample>
	| fixture model memento source copy |
	fixture := self fixture.
	model := fixture first. memento := fixture second. source := fixture third. copy := fixture fourth.
	self assert: (self copy: source copiedObject: copy memento: memento at: 2) apply isApplicable.
	memento commit.
	self assert: model leftItems first == source.
	self assert: model rightItems second == copy.
	self assert: model rightItems second ~~ source.
	^ model
]

{ #category : 'examples - assessment' }
CFAtelierCopyExamples >> sourceIdentityIsNotAcceptedAsCopy [
	<gtExample>
	| fixture memento source assessment |
	fixture := self fixture. memento := fixture second. source := fixture third.
	assessment := (self copy: source copiedObject: source memento: memento at: 2) assess.
	self assert: assessment isApplicable not.
	self assert: assessment rejectionMessage equals: 'Copy requires a distinct materialized object identity; reusing the source identity is reference, not copy.'.
	^ assessment
]

{ #category : 'examples - assessment' }
CFAtelierCopyExamples >> staleSourceIsRejectedOnApply [
	<gtExample>
	| fixture memento source copy operation leftDescription assessment |
	fixture := self fixture. memento := fixture second. source := fixture third. copy := fixture fourth.
	operation := self copy: source copiedObject: copy memento: memento at: 2.
	self assert: operation assess isApplicable.
	leftDescription := self descriptionFor: #leftItems in: memento.
	memento write: OrderedCollection new using: leftDescription.
	assessment := operation apply.
	self assert: assessment isApplicable not.
	self assert: (memento readUsing: (self descriptionFor: #rightItems in: memento)) size equals: 1.
	^ assessment
]

{ #category : 'examples - cardinality' }
CFAtelierCopyExamples >> copiesFromToOneIntoUnorderedToMany [
	<gtExample>
	| model source copy memento sourceDescription destinationDescription operation assessment |
	model := CFAtelierMoveExampleModel new.
	source := Object new.
	copy := Object new.
	model leftItem: source.
	model looseItems: OrderedCollection new.
	memento := CFMaMemento model: model.
	sourceDescription := self descriptionFor: #leftItem in: memento.
	destinationDescription := self descriptionFor: #looseItems in: memento.
	operation := CFAtelierCopy
		sourceObject: source
		copiedObject: copy
		sourceMemento: memento
		sourceDescription: sourceDescription
		destinationMemento: memento
		destinationDescription: destinationDescription
		destinationIndex: nil.
	assessment := operation apply.
	self assert: assessment isApplicable.
	self assert: (memento readUsing: sourceDescription) == source.
	self assert: (memento readUsing: destinationDescription) first == copy.
	self assert: model looseItems isEmpty.
	^ assessment
]

{ #category : 'examples - cardinality' }
CFAtelierCopyExamples >> copiesFromToManyIntoEmptyToOne [
	<gtExample>
	| model source copy memento sourceDescription destinationDescription operation assessment |
	model := CFAtelierMoveExampleModel new.
	source := Object new.
	copy := Object new.
	model leftItems: (OrderedCollection with: source).
	memento := CFMaMemento model: model.
	sourceDescription := self descriptionFor: #leftItems in: memento.
	destinationDescription := self descriptionFor: #rightItem in: memento.
	operation := CFAtelierCopy
		sourceObject: source
		copiedObject: copy
		sourceMemento: memento
		sourceDescription: sourceDescription
		destinationMemento: memento
		destinationDescription: destinationDescription
		destinationIndex: nil.
	assessment := operation apply.
	self assert: assessment isApplicable.
	self assert: (memento readUsing: sourceDescription) first == source.
	self assert: (memento readUsing: destinationDescription) == copy.
	self assert: model rightItem isNil.
	^ assessment
]

{ #category : 'examples - cardinality' }
CFAtelierCopyExamples >> occupiedToOneDestinationRejectsCopy [
	<gtExample>
	| model source copy existing memento operation assessment |
	model := CFAtelierMoveExampleModel new.
	source := Object new.
	copy := Object new.
	existing := Object new.
	model leftItems: (OrderedCollection with: source).
	model rightItem: existing.
	memento := CFMaMemento model: model.
	operation := CFAtelierCopy
		sourceObject: source
		copiedObject: copy
		sourceMemento: memento
		sourceDescription: (self descriptionFor: #leftItems in: memento)
		destinationMemento: memento
		destinationDescription: (self descriptionFor: #rightItem in: memento)
		destinationIndex: nil.
	assessment := operation assess.
	self assert: assessment isApplicable not.
	self assert: assessment rejectionMessage equals: 'A to-one destination must be empty for a copy.'.
	self assert: (memento readUsing: (self descriptionFor: #rightItem in: memento)) == existing.
	^ assessment
]

{ #category : 'examples - cardinality' }
CFAtelierCopyExamples >> unorderedDestinationRejectsInsertionIndex [
	<gtExample>
	| model source copy memento operation assessment |
	model := CFAtelierMoveExampleModel new.
	source := Object new.
	copy := Object new.
	model leftItems: (OrderedCollection with: source).
	model looseItems: OrderedCollection new.
	memento := CFMaMemento model: model.
	operation := CFAtelierCopy
		sourceObject: source
		copiedObject: copy
		sourceMemento: memento
		sourceDescription: (self descriptionFor: #leftItems in: memento)
		destinationMemento: memento
		destinationDescription: (self descriptionFor: #looseItems in: memento)
		destinationIndex: 1.
	assessment := operation assess.
	self assert: assessment isApplicable not.
	self assert: assessment rejectionMessage equals: 'An unordered destination does not accept an insertion index.'.
	^ assessment
]

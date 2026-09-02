"I am the public view-model entry point for editing an ordinary Magritte-described object as a Foundation Atelier.

I deliberately inherit Foundation Magritte's rendering and memento behaviour unchanged. Atelier does not choose a parallel presentation: the object's Magritte container continues to select its Foundation presentation through the existing CFMaViewModel machinery.

When Atelier-owned orchestration UI such as a palette is configured, I arrange it around that unchanged Foundation form rather than rendering the form myself."
Class {
	#name : 'CFAtelierViewModel',
	#superclass : 'CFMaViewModel',
	#instVars : [
		'palette',
		'removeOperationBlock',
		'insertOperationBlock',
		'replaceOperationBlock',
		'moveOperationBlock',
		'reorderOperationBlock'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'api - converting' }
CFAtelierViewModel >> asElement [
	| aFormElement |
	self presentationDo: [ :aPresentation |
		aPresentation
			relationItemElementDo: [ :aRow :anObject :aDescription :aMemento |
				(CFAtelierRelationDropTarget
					installOn: aRow
					targetObject: anObject
					memento: aMemento
					description: aDescription)
					insertOperationFor: insertOperationBlock;
					replaceOperationFor: replaceOperationBlock;
					moveOperationFor: moveOperationBlock ];
			relationElementDo: [ :aRelationElement :aDescription :aMemento |
				(CFAtelierRelationDropSurface
					installOn: aRelationElement
					memento: aMemento
					description: aDescription)
					insertOperationFor: insertOperationBlock;
					moveOperationFor: moveOperationBlock.
				(CFAtelierToOneDropTarget
					installOn: aRelationElement
					memento: aMemento
					description: aDescription)
					replaceOperationFor: replaceOperationBlock;
					moveOperationFor: moveOperationBlock ];
			relationReorderDo: [ :someObjects :aTargetObject :aMemento :aDescription :placeAfter |
				self
					applyReorderOf: someObjects first
					relativeTo: aTargetObject
					after: placeAfter
					memento: aMemento
					description: aDescription ] ].
	aFormElement := super asElement.
	palette ifNil: [ ^ aFormElement ].
	^ CFAtelierElement new
		removeOperationFor: removeOperationBlock;
		palette: palette;
		formElement: aFormElement;
		yourself
]


{ #category : 'configuration' }
CFAtelierViewModel >> configuration: anAtelierConfiguration [
	anAtelierConfiguration applyTo: self
]

{ #category : 'accessing' }
CFAtelierViewModel >> palette [
	^ palette
]

{ #category : 'accessing' }
CFAtelierViewModel >> palette: anAtelierPalette [
	palette := anAtelierPalette
]

{ #category : 'configuration' }
CFAtelierViewModel >> removeOperationFor: aBlock [
	"Configure how Atelier interprets an explicit remove drop for an existing relation object. The block receives the dragged object and its CFAtelierRelationDragContext and answers the operation to assess/apply. Leave unset for generic CFAtelierRemove semantics."
	removeOperationBlock := aBlock
]

{ #category : 'configuration' }
CFAtelierViewModel >> insertOperationFor: aBlock [
	"Configure how a palette insertion candidate becomes an operation. The block receives candidate, destination memento, destination description and insertion index (nil for unordered relations). Leave unset for generic CFAtelierInsert semantics."
	insertOperationBlock := aBlock
]

{ #category : 'configuration' }
CFAtelierViewModel >> replaceOperationFor: aBlock [
	"Configure how a palette replacement candidate becomes an operation. The block receives candidate, current object, destination memento and destination description. Leave unset for generic CFAtelierReplace semantics."
	replaceOperationBlock := aBlock
]

{ #category : 'configuration' }
CFAtelierViewModel >> moveOperationFor: aBlock [
	"Configure how an existing relation object moves to another relation. The block receives the exact object, source CFAtelierRelationDragContext, destination CFAtelierRelationDragContext and destination index (nil for unordered or to-one destinations). Leave unset for generic CFAtelierMove semantics."
	moveOperationBlock := aBlock
]


{ #category : 'configuration' }
CFAtelierViewModel >> reorderOperationFor: aBlock [
	"Configure how Atelier interprets Foundation's existing single-item reorder gesture. The block receives the exact object, memento, relation description and final destination index. Leave unset for generic CFAtelierReorder semantics."
	reorderOperationBlock := aBlock
]

{ #category : 'operations' }
CFAtelierViewModel >> reorderOperationFor: anObject relativeTo: aTargetObject after: placeAfter memento: aMemento description: aDescription [
	| items remainingItems targetIndex destinationIndex |
	items := aMemento readUsing: aDescription.
	items ifNil: [
		^ CFAtelierReorder object: anObject memento: aMemento description: aDescription to: 0 ].
	remainingItems := items reject: [ :each | each == anObject ].
	targetIndex := remainingItems identityIndexOf: aTargetObject ifAbsent: [ 0 ].
	destinationIndex := placeAfter
		ifTrue: [ targetIndex + 1 ]
		ifFalse: [ targetIndex ].
	reorderOperationBlock ifNotNil: [
		^ reorderOperationBlock
			value: anObject
			value: aMemento
			value: aDescription
			value: destinationIndex ].
	^ CFAtelierReorder
		object: anObject
		memento: aMemento
		description: aDescription
		to: destinationIndex
]

{ #category : 'operations' }
CFAtelierViewModel >> applyReorderOf: anObject relativeTo: aTargetObject after: placeAfter memento: aMemento description: aDescription [
	^ (self
		reorderOperationFor: anObject
		relativeTo: aTargetObject
		after: placeAfter
		memento: aMemento
		description: aDescription) apply
]

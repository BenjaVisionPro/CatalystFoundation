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
					applyReorderOf: someObjects
					relativeTo: aTargetObject
					after: placeAfter
					memento: aMemento
					description: aDescription ];
			relationRemoveDo: [ :someObjects :aMemento :aDescription |
				self
					applyRemoveOf: someObjects
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
	"Configure how Atelier interprets removal of one or more objects from one relation. The block receives the objects collection and a CFAtelierRelationDragContext describing the source editing context, and answers one operation for the complete intention. Leave unset for generic CFAtelierRemove semantics."
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
	"Configure how an existing relation object moves to another relation. The block receives the moved objects collection, source CFAtelierRelationDragContext, destination CFAtelierRelationDragContext and destination index (nil for unordered or to-one destinations). Leave unset for generic CFAtelierMove semantics."
	moveOperationBlock := aBlock
]


{ #category : 'configuration' }
CFAtelierViewModel >> reorderOperationFor: aBlock [
	"Configure how Atelier interprets Foundation's existing reorder gesture. The block receives the dragged objects in relation order, memento, relation description and the first final index occupied by the moved group. Leave unset for generic CFAtelierReorder semantics."
	reorderOperationBlock := aBlock
]

{ #category : 'operations' }
CFAtelierViewModel >> reorderOperationFor: someObjects relativeTo: aTargetObject after: placeAfter memento: aMemento description: aDescription [
	| items draggedItems remainingItems targetIndex destinationIndex |
	items := aMemento readUsing: aDescription.
	items ifNil: [
		^ CFAtelierReorder objects: someObjects memento: aMemento description: aDescription to: 0 ].
	draggedItems := items select: [ :each |
		someObjects anySatisfy: [ :anObject | anObject == each ] ].
	remainingItems := items reject: [ :each |
		draggedItems anySatisfy: [ :anObject | anObject == each ] ].
	targetIndex := remainingItems identityIndexOf: aTargetObject ifAbsent: [ 0 ].
	destinationIndex := placeAfter
		ifTrue: [ targetIndex + 1 ]
		ifFalse: [ targetIndex ].
	reorderOperationBlock ifNotNil: [
		^ reorderOperationBlock
			value: draggedItems
			value: aMemento
			value: aDescription
			value: destinationIndex ].
	^ CFAtelierReorder
		objects: draggedItems
		memento: aMemento
		description: aDescription
		to: destinationIndex
]

{ #category : 'operations' }
CFAtelierViewModel >> applyReorderOf: someObjects relativeTo: aTargetObject after: placeAfter memento: aMemento description: aDescription [
	^ (self
		reorderOperationFor: someObjects
		relativeTo: aTargetObject
		after: placeAfter
		memento: aMemento
		description: aDescription) apply
]


{ #category : 'operations' }
CFAtelierViewModel >> removeOperationFor: someObjects memento: aMemento description: aDescription [
	| aContext |
	aContext := CFAtelierRelationDragContext
		memento: aMemento
		description: aDescription.
	removeOperationBlock ifNotNil: [
		^ removeOperationBlock value: someObjects value: aContext ].
	^ CFAtelierRemove
		objects: someObjects
		memento: aMemento
		description: aDescription
]

{ #category : 'operations' }
CFAtelierViewModel >> applyRemoveOf: someObjects memento: aMemento description: aDescription [
	^ (self
		removeOperationFor: someObjects
		memento: aMemento
		description: aDescription) apply
]

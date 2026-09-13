"I am the public view-model entry point for editing an ordinary Magritte-described object as a Foundation Atelier.

I inherit Foundation Magritte's rendering and memento behaviour. The object's Magritte container still selects its Foundation presentation; Atelier composes its shared workspace host, inspector browser and optional palette around that form."
Class {
	#name : 'CFAtelierViewModel',
	#superclass : 'CFMaViewModel',
	#instVars : [
		'palette',
		'paletteElementFactory',
		'removeOperationBlock',
		'insertOperationBlock',
		'replaceOperationBlock',
		'moveOperationBlock',
		'reorderOperationBlock',
		'clientPresentationBlock',
		'atelierElement',
		'pendingInspectorRequest'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'api - converting' }
CFAtelierViewModel >> asElement [
	| aFormElement |
	aFormElement := self newFormElement.
	atelierElement ifNil: [
		atelierElement := CFAtelierElement new
			removeOperationFor: removeOperationBlock;
			yourself ].
	atelierElement formElement: aFormElement.
	palette ifNotNil: [
		atelierElement palette: palette elementFactory: paletteElementFactory ].
	self applyPendingInspectorRequest.
	^ atelierElement
]

{ #category : 'private - building' }
CFAtelierViewModel >> newFormElement [
	super presentationDo: [ :aPresentation |
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
					description: aDescription ].
		clientPresentationBlock ifNotNil: [ :aBlock | aBlock value: aPresentation ] ].
	^ super asElement
]

{ #category : 'private - building' }
CFAtelierViewModel >> newFormElementIn: anAtelierElement [
	atelierElement := anAtelierElement.
	^ self newFormElement
]



{ #category : 'configuration' }
CFAtelierViewModel >> presentationDo: aBlock [
	"Configure the Foundation-selected presentation for this Atelier client. Atelier composes this block with its own relation interaction hooks when the presentation is built."
	clientPresentationBlock := aBlock
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
CFAtelierViewModel >> paletteElementFactory: aBlock [
	paletteElementFactory := aBlock
]

{ #category : 'accessing' }
CFAtelierViewModel >> paletteElementFactory [
	^ paletteElementFactory
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


{ #category : 'inspecting' }
CFAtelierViewModel >> clearInspector [
	pendingInspectorRequest := nil.
	atelierElement ifNotNil: [ atelierElement clearInspector ]
]

{ #category : 'inspecting' }
CFAtelierViewModel >> inspectObject: anObject memento: aMemento presentationDo: aBlock [
	pendingInspectorRequest := { anObject. aMemento. aBlock }.
	self applyPendingInspectorRequest
]

{ #category : 'private - inspecting' }
CFAtelierViewModel >> applyPendingInspectorRequest [
	| request |
	(atelierElement isNil or: [ pendingInspectorRequest isNil ]) ifTrue: [ ^ self ].
	request := pendingInspectorRequest.
	pendingInspectorRequest := nil.
	atelierElement
		inspectObject: request first
		memento: request second
		presentationDo: request third
]

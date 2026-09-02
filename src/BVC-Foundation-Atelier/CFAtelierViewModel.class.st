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
		'replaceOperationBlock'
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
					replaceOperationFor: replaceOperationBlock ];
			relationElementDo: [ :aRelationElement :aDescription :aMemento |
				(CFAtelierRelationDropSurface
					installOn: aRelationElement
					memento: aMemento
					description: aDescription)
					insertOperationFor: insertOperationBlock.
				(CFAtelierToOneDropTarget
					installOn: aRelationElement
					memento: aMemento
					description: aDescription)
					replaceOperationFor: replaceOperationBlock ] ].
	aFormElement := super asElement.
	palette ifNil: [ ^ aFormElement ].
	^ CFAtelierElement new
		removeOperationFor: removeOperationBlock;
		palette: palette;
		formElement: aFormElement;
		yourself
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

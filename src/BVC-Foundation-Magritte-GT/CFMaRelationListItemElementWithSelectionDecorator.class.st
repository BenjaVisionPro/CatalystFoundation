Class {
	#name : 'CFMaRelationListItemElementWithSelectionDecorator',
	#superclass : 'BrListItemElementStencilBuilder',
	#instVars : [
		'stencilBuilder'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'accessing' }
CFMaRelationListItemElementWithSelectionDecorator class >> stencilProperties [
	^ #(stencilBuilder)
]

{ #category : 'api - instantiation' }
CFMaRelationListItemElementWithSelectionDecorator >> buildDefault [
	| anElement |

	anElement := stencilBuilder
		itemType: self itemType;
		build.

	anElement addAptitude: CFMaRelationListItemAptitude.

	^ anElement
]

{ #category : 'accessing' }
CFMaRelationListItemElementWithSelectionDecorator >> stencilBuilder [
	^ stencilBuilder
]

{ #category : 'accessing' }
CFMaRelationListItemElementWithSelectionDecorator >> stencilBuilder: anObject [
	stencilBuilder := anObject
]

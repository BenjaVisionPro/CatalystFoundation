Class {
	#name : 'CFMaListItemElementStencilBuilder',
	#superclass : 'BrListItemElementStencilBuilder',
	#instVars : [
		'stencilBuilder'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'accessing' }
CFMaListItemElementStencilBuilder class >> stencilProperties [
	^ #(stencilBuilder)
]

{ #category : 'api - instantiation' }
CFMaListItemElementStencilBuilder >> buildDefault [
	| anElement |

	anElement := stencilBuilder
		itemType: self itemType;
		build.

	anElement addAptitude: CFMaFocusAwareListItemAptitude.

	^ anElement
]

{ #category : 'accessing' }
CFMaListItemElementStencilBuilder >> stencilBuilder [
	^ stencilBuilder
]

{ #category : 'accessing' }
CFMaListItemElementStencilBuilder >> stencilBuilder: anObject [
	stencilBuilder := anObject
]

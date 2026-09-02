"I am an explicitly configured collection of reusable Atelier palette items.

I deliberately know nothing about Magritte targets, placement, drag/drop, serialization, discovery or operation kinds. A presentation can expose my items; an interaction materializes one selected item once and then creates the appropriate Atelier/client operation with that candidate."
Class {
	#name : 'CFAtelierPalette',
	#superclass : 'Object',
	#instVars : [
		'items'
	],
	#category : 'BVC-Foundation-Atelier-Palette',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Palette'
}

{ #category : 'adding' }
CFAtelierPalette >> add: aPaletteItem [
	items add: aPaletteItem.
	^ aPaletteItem
]

{ #category : 'adding' }
CFAtelierPalette >> addAll: aCollection [
	aCollection do: [ :each | self add: each ]
]

{ #category : 'initialization' }
CFAtelierPalette >> initialize [
	super initialize.
	items := OrderedCollection new
]

{ #category : 'accessing' }
CFAtelierPalette >> items [
	^ items
]

"I am an explicitly configured collection of reusable Atelier palette items.

I deliberately know nothing about Magritte targets, placement, serialization, discovery or operation kinds. A presentation can expose my items; an interaction materializes one selected item once and then creates the appropriate Atelier/client operation with that candidate.

A client may additionally configure captureUsing:. That block is the palette-specific seam for turning an object dragged back from a composition into a reusable palette item. The palette therefore decides whether capture means retaining identity, taking a copy, storing a serialised definition, creating factory data, or something application-specific; Atelier does not impose that storage policy."
Class {
	#name : 'CFAtelierPalette',
	#superclass : 'Object',
	#instVars : [
		'items',
		'captureBlock'
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


{ #category : 'capturing' }
CFAtelierPalette >> capture: anObject [
	| anItem |
	captureBlock ifNil: [ ^ nil ].
	anItem := captureBlock value: anObject.
	anItem ifNil: [ ^ nil ].
	self add: anItem.
	^ anItem
]

{ #category : 'capturing' }
CFAtelierPalette >> captureUsing: aBlock [
	captureBlock := aBlock
]

{ #category : 'testing' }
CFAtelierPalette >> canCapture [
	^ captureBlock notNil
]

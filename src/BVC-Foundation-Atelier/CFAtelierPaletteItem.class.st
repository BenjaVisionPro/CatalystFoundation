"I am one configured entry in an Atelier palette.

I give presentation-facing identity to an object provider without taking over provider semantics. materialize delegates exactly once to my provider when a caller requests a candidate. I do not assess placement, retain a materialized candidate, or imply create/copy/reference semantics; the operation chosen by the interaction owns those meanings."
Class {
	#name : 'CFAtelierPaletteItem',
	#superclass : 'Object',
	#instVars : [
		'label',
		'provider'
	],
	#category : 'BVC-Foundation-Atelier-Palette',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Palette'
}

{ #category : 'instance creation' }
CFAtelierPaletteItem class >> label: aString provider: anObjectProvider [
	^ self new
		label: aString;
		provider: anObjectProvider;
		yourself
]

{ #category : 'accessing' }
CFAtelierPaletteItem >> label [
	^ label
]

{ #category : 'accessing' }
CFAtelierPaletteItem >> label: aString [
	label := aString
]

{ #category : 'materializing' }
CFAtelierPaletteItem >> materialize [
	^ provider materialize
]

{ #category : 'accessing' }
CFAtelierPaletteItem >> provider [
	^ provider
]

{ #category : 'accessing' }
CFAtelierPaletteItem >> provider: anObjectProvider [
	provider := anObjectProvider
]

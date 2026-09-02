"I prove the empty-root Atelier entry path and root adoption semantics."
Class {
	#name : 'CFAtelierEmptyEntryExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - entry' }
CFAtelierEmptyEntryExamples >> emptyAtelierHasPaletteAndRootTarget [
	<gtExample>
	| palette atelier element |
	palette := self examplePalette.
	atelier := CFAtelierEmptyViewModel palette: palette.
	element := atelier asElement.

	self assert: element class equals: CFAtelierElement.
	self assert: element paletteElement palette == palette.
	self assert: element formElement class equals: CFAtelierEmptyRootElement.
	self assert: atelier rootObject isNil.
	^ atelier
]

{ #category : 'examples - entry' }
CFAtelierEmptyEntryExamples >> adoptingRootUsesExactSuppliedIdentity [
	<gtExample>
	| atelier candidate accepted |
	atelier := CFAtelierEmptyViewModel palette: self examplePalette.
	atelier asElement.
	candidate := CFAtelierEntryExampleModel new.

	accepted := atelier adoptRootObject: candidate.

	self assert: accepted.
	self assert: atelier rootObject == candidate.
	self assert: atelier asElement formElement class equals: CFMaFormRootElement.
	^ atelier
]

{ #category : 'examples - entry' }
CFAtelierEmptyEntryExamples >> rejectingNonMagritteRootLeavesAtelierEmpty [
	<gtExample>
	| atelier candidate accepted |
	atelier := CFAtelierEmptyViewModel palette: self examplePalette.
	atelier asElement.
	candidate := Object new.

	accepted := atelier adoptRootObject: candidate.

	self assert: accepted not.
	self assert: atelier rootObject isNil.
	self assert: atelier asElement formElement class equals: CFAtelierEmptyRootElement.
	^ atelier
]

{ #category : 'private - examples' }
CFAtelierEmptyEntryExamples >> examplePalette [
	| palette |
	palette := CFAtelierPalette new.
	palette add: (CFAtelierPaletteItem
		label: 'New example'
		provider: (CFAtelierFactoryProvider factory: [ CFAtelierEntryExampleModel new ])).
	^ palette
]

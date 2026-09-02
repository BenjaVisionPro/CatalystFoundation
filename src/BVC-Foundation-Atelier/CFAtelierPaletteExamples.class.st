"I prove the deliberately small Atelier palette configuration seam independently of UI and operation semantics."
Class {
	#name : 'CFAtelierPaletteExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - palette' }
CFAtelierPaletteExamples >> palettePreservesConfiguredItemOrder [
	<gtExample>
	| palette first second |
	palette := CFAtelierPalette new.
	first := CFAtelierPaletteItem
		label: 'First'
		provider: (CFAtelierFactoryProvider factory: [ Object new ]).
	second := CFAtelierPaletteItem
		label: 'Second'
		provider: (CFAtelierFactoryProvider factory: [ Object new ]).
	palette
		add: first;
		add: second.

	self assert: palette items size equals: 2.
	self assert: palette items first == first.
	self assert: palette items second == second.
	^ palette
]

{ #category : 'examples - palette' }
CFAtelierPaletteExamples >> paletteItemDelegatesMaterializationToProvider [
	<gtExample>
	| provider item first second |
	provider := CFAtelierFactoryProvider factory: [ Object new ].
	item := CFAtelierPaletteItem label: 'Object' provider: provider.

	first := item materialize.
	second := item materialize.

	self assert: first ~~ second.
	self assert: item provider == provider.
	^ item
]

"I prove that Atelier orchestration configuration is reusable across existing-root and empty-root entry paths without becoming Foundation presentation configuration."
Class {
	#name : 'CFAtelierConfigurationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'private - examples' }
CFAtelierConfigurationExamples >> exampleConfiguration [
	| palette configuration |
	palette := CFAtelierPalette new.
	palette add: (CFAtelierPaletteItem
		label: 'New example'
		provider: (CFAtelierFactoryProvider factory: [ CFAtelierEntryExampleModel new ])).
	configuration := CFAtelierConfiguration new.
	configuration
		palette: palette;
		insertOperationFor: [ :candidate :memento :description :index |
			index
				ifNil: [ CFAtelierInsert object: candidate memento: memento description: description ]
				ifNotNil: [ CFAtelierInsert object: candidate memento: memento description: description at: index ] ].
	^ configuration
]

{ #category : 'examples - configuration' }
CFAtelierConfigurationExamples >> existingObjectEntryUsesConfiguredPalette [
	<gtExample>
	| model configuration atelier element |
	model := CFAtelierEntryExampleModel new.
	configuration := self exampleConfiguration.
	atelier := model asAtelierWith: configuration.
	element := atelier asElement.

	self assert: element class equals: CFAtelierElement.
	self assert: element paletteElement palette == configuration palette.
	^ atelier
]

{ #category : 'examples - configuration' }
CFAtelierConfigurationExamples >> emptyRootReusesEditingConfigurationAfterAdoption [
	<gtExample>
	| configuration atelier candidate accepted |
	configuration := self exampleConfiguration.
	atelier := CFAtelierEmptyViewModel configuration: configuration.
	atelier asElement.
	candidate := CFAtelierEntryExampleModel new.

	accepted := atelier adoptRootObject: candidate.

	self assert: accepted.
	self assert: atelier rootObject == candidate.
	self assert: atelier rootViewModel notNil.
	self assert: atelier rootViewModel palette isNil.
	self assert: atelier asElement paletteElement palette == configuration palette.
	^ atelier
]

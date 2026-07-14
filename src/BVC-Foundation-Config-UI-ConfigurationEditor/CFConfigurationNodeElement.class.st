Class {
	#name : 'CFConfigurationNodeElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'configuration',
		'memento',
		'visitedConfigurations',
		'selectedConfiguration',
		'selectionBlock'
	],
	#category : 'BVC-Foundation-Config-UI-ConfigurationEditor',
	#package : 'BVC-Foundation-Config-UI-ConfigurationEditor'
}

{ #category : 'instance creation' }
CFConfigurationNodeElement class >> configuration: aConfiguration visited: aSet [
	^ self new
		visitedConfigurations: aSet;
		configuration: aConfiguration;
		yourself
]

{ #category : 'instance creation' }
CFConfigurationNodeElement class >> configuration: aConfiguration visited: aSet selected: aSelectedConfiguration whenSelected: aBlock [
	^ self new
		visitedConfigurations: aSet;
		selectedConfiguration: aSelectedConfiguration;
		whenSelectedDo: aBlock;
		configuration: aConfiguration;
		yourself
]


{ #category : 'accessing' }
CFConfigurationNodeElement >> configuration: aConfiguration [
	configuration := aConfiguration.
	memento := GtMagritteMemento model: aConfiguration.
	visitedConfigurations ifNil: [
		visitedConfigurations := IdentitySet new.
		visitedConfigurations add: aConfiguration ].
	self refresh
]

{ #category : 'private - building' }
CFConfigurationNodeElement >> createMagritteFormElement [
	| formViewModel formRootElement |
	formViewModel := CFMaViewModel
		forObject: configuration
		description: [ memento magritteDescription ].
	formViewModel elementBuilderDo: [
		CFConfigurationMaElementBuilder new
			visitedConfigurations: visitedConfigurations;
			selectedConfiguration: selectedConfiguration;
			whenSelectedDo: selectionBlock;
			yourself ].
	formViewModel formElementDo: [ :aFormElement |
		aFormElement
			selected: self isSelected;
			beCollapsed.
		aFormElement headerElement when: BlClickEvent do: [ :anEvent |
			selectionBlock ifNotNil: [ :aBlock | aBlock value: configuration ] ] ].
	formRootElement := formViewModel asEmbeddedElement.
	formRootElement
		hMatchParent;
		vFitContent;
		yourself.
	^ formRootElement
]


{ #category : 'initialization' }
CFConfigurationNodeElement >> initialize [
	super initialize.
	self
		hMatchParent;
		vFitContent;
		padding: BlInsets empty;
		cellSpacing: 10;
		background: Color transparent;
		border: BlBorder empty
]

{ #category : 'testing' }
CFConfigurationNodeElement >> isSelected [
	^ configuration == selectedConfiguration
]

{ #category : 'updating' }
CFConfigurationNodeElement >> refresh [
	configuration ifNil: [ ^ self ].
	self removeChildren.
	self addChild: self createMagritteFormElement
]

{ #category : 'accessing' }
CFConfigurationNodeElement >> selectedConfiguration: aConfiguration [
	selectedConfiguration := aConfiguration
]

{ #category : 'accessing' }
CFConfigurationNodeElement >> visitedConfigurations: aSet [
	visitedConfigurations := aSet
]

{ #category : 'events' }
CFConfigurationNodeElement >> whenSelectedDo: aBlock [
	selectionBlock := aBlock
]

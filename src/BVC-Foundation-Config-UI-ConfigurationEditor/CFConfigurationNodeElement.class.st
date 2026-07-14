Class {
	#name : 'CFConfigurationNodeElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'configuration',
		'memento',
		'visitedConfigurations',
		'selectedConfiguration',
		'selectionBlock',
		'formElement',
		'expandedConfigurations'
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


{ #category : 'instance creation' }
CFConfigurationNodeElement class >> configuration: aConfiguration visited: aSet expandedConfigurations: anIdentitySet selected: aSelectedConfiguration whenSelected: aBlock [
	^ self new
		visitedConfigurations: aSet;
		expandedConfigurations: anIdentitySet;
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
			expandedConfigurations: expandedConfigurations;
			selectedConfiguration: selectedConfiguration;
			whenSelectedDo: selectionBlock;
			yourself ].
	formViewModel formElementDo: [ :aFormElement |
		formElement := aFormElement.
		aFormElement selected: self isSelected.
		(expandedConfigurations includes: configuration)
			ifTrue: [ aFormElement beExpanded ]
			ifFalse: [ aFormElement beCollapsed ].
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
	expandedConfigurations := IdentitySet new.
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


{ #category : 'accessing' }
CFConfigurationNodeElement >> configuration [
	^ configuration
]

{ #category : 'accessing' }
CFConfigurationNodeElement >> formElement [
	^ formElement
]

{ #category : 'testing' }
CFConfigurationNodeElement >> isExpanded [
	^ formElement notNil and: [ formElement expanded ]
]

{ #category : 'configuration' }
CFConfigurationNodeElement >> beExpanded [
	expandedConfigurations add: configuration.
	formElement ifNotNil: [ :anElement | anElement beExpanded ]
]

{ #category : 'configuration' }
CFConfigurationNodeElement >> beCollapsed [
	expandedConfigurations remove: configuration ifAbsent: [ ].
	formElement ifNotNil: [ :anElement | anElement beCollapsed ]
]


{ #category : 'accessing' }
CFConfigurationNodeElement >> expandedConfigurations: anIdentitySet [
	expandedConfigurations := anIdentitySet
]

{ #category : 'committing' }
CFConfigurationNodeElement >> commitPreviewWithConfiguration: aConfiguration selected: aSelectedConfiguration whenSelected: aBlock [
	configuration == aConfiguration ifFalse: [
		self error: 'A placement preview can only commit the configuration it already renders.' ].
	selectedConfiguration := aSelectedConfiguration.
	selectionBlock := aBlock.
	formElement ifNotNil: [ :anElement |
		anElement selected: self isSelected ].
	self allowMouseEvents
]


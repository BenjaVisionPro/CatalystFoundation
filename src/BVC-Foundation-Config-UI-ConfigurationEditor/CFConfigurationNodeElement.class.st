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

{ #category : 'private - building' }
CFConfigurationNodeElement >> configurationChildrenFor: aDescription [
	| value |
	value := memento readUsing: aDescription.
	value ifNil: [ ^ #() ].
	(value isCollection and: [ value isString not ])
		ifTrue: [ ^ value select: [ :each | each isKindOf: CFConfiguration ] ].
	^ (value isKindOf: CFConfiguration)
		ifTrue: [ { value } ]
		ifFalse: [ #() ]
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
	| formDescription formViewModel formRootElement |
	formDescription := (memento magritteDescription
		select: [ :each | (each isKindOf: MARelationDescription) not ]) asContainer.
	formViewModel := CFMaViewModel
		forObject: configuration
		description: [ formDescription ].
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

{ #category : 'private - building' }
CFConfigurationNodeElement >> createRelationElementFor: aDescription [
	| relationElement heading items children |
	relationElement := CFConfigurationRelationElement new
		memento: memento;
		description: aDescription;
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 9);
		cellSpacing: 6;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		background: (Color white alpha: 0.72);
		border: (BlBorder paint: (Color black alpha: 0.10) width: 1);
		yourself.
	heading := BrLabel new
		hMatchParent;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFont;
			fontSize: 12;
			foreground: (Color black alpha: 0.56);
			yourself);
		text: aDescription label;
		yourself.
	items := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 5;
		yourself.
	relationElement relationItemsElement: items.
	children := self configurationChildrenFor: aDescription.
	children do: [ :each |
		(visitedConfigurations includes: each) ifFalse: [
			| childVisited |
			childVisited := visitedConfigurations copy.
			childVisited add: each.
			items addChild: (self class
				configuration: each
				visited: childVisited
				selected: selectedConfiguration
				whenSelected: selectionBlock) ] ].
	relationElement
		addChild: heading;
		addChild: items.
	^ relationElement
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
	self addChild: self createMagritteFormElement.
	(memento magritteDescription
		select: [ :each | each isKindOf: MARelationDescription ])
		do: [ :each | self addChild: (self createRelationElementFor: each) ]
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

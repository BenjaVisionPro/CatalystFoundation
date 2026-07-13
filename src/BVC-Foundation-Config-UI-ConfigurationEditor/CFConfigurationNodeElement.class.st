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
CFConfigurationNodeElement >> createHeaderElement [
	| header compact |
	header := BrFrame new
		hMatchParent;
		vFitContent;
		layout: BlFrameLayout new;
		padding: (BlInsets all: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 11);
		background: (self isSelected
			ifTrue: [ Color r: 0.16 g: 0.45 b: 0.88 alpha: 0.16 ]
			ifFalse: [ Color white alpha: 0.98 ]);
		border: (BlBorder paint: (self isSelected
			ifTrue: [ Color r: 0.18 g: 0.50 b: 0.96 alpha: 0.95 ]
			ifFalse: [ Color black alpha: 0.14 ]) width: (self isSelected ifTrue: [ 2 ] ifFalse: [ 1 ]));
		yourself.
	compact := CFCompactObjectStencil new
		object: configuration;
		create.
	compact
		hMatchParent;
		padding: (BlInsets top: 10 left: 12 bottom: 10 right: 12);
		yourself.
	header
		addChild: compact;
		when: BlClickEvent do: [ :anEvent |
			selectionBlock ifNotNil: [ :aBlock | aBlock value: configuration ].
			anEvent consumed: true ].
	^ header
]


{ #category : 'private - building' }
CFConfigurationNodeElement >> createMagritteFormElement [
	| formDescription formElement |
	formDescription := (memento magritteDescription
		select: [ :each | (each isKindOf: MARelationDescription) not ]) asContainer.
	formElement := (CFMaViewModel
		forObject: configuration
		description: [ formDescription ]) asElement.
	formElement
		hMatchParent;
		vFitContent;
		yourself.
	^ formElement
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
		padding: (BlInsets all: 12);
		cellSpacing: 10;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 14);
		background: (Color r: 0.86 g: 0.91 b: 0.98 alpha: 0.42);
		border: (BlBorder paint: (Color r: 0.26 g: 0.47 b: 0.76 alpha: 0.35) width: 1)
]

{ #category : 'testing' }
CFConfigurationNodeElement >> isSelected [
	^ configuration == selectedConfiguration
]

{ #category : 'updating' }
CFConfigurationNodeElement >> refresh [
	configuration ifNil: [ ^ self ].
	self removeChildren.
	self
		addChild: self createHeaderElement;
		addChild: self createMagritteFormElement.
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

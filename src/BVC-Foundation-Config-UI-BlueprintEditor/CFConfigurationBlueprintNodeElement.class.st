Class {
	#name : 'CFConfigurationBlueprintNodeElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'configuration',
		'visitedConfigurations',
		'selectedConfiguration',
		'selectionBlock'
	],
	#category : 'BVC-Foundation-Config-UI-BlueprintEditor',
	#package : 'BVC-Foundation-Config-UI-BlueprintEditor'
}

{ #category : 'instance creation' }
CFConfigurationBlueprintNodeElement class >> configuration: aConfiguration visited: aSet [
	^ self new
		visitedConfigurations: aSet;
		configuration: aConfiguration;
		yourself
]

{ #category : 'instance creation' }
CFConfigurationBlueprintNodeElement class >> configuration: aConfiguration visited: aSet selected: aSelectedConfiguration whenSelected: aBlock [
	^ self new
		visitedConfigurations: aSet;
		selectedConfiguration: aSelectedConfiguration;
		whenSelectedDo: aBlock;
		configuration: aConfiguration;
		yourself
]

{ #category : 'private - building' }
CFConfigurationBlueprintNodeElement >> configurationChildrenFor: aDescription [
	| value |
	value := configuration readUsing: aDescription.
	value ifNil: [ ^ #() ].
	(value isCollection and: [ value isString not ])
		ifTrue: [ ^ value select: [ :each | each isKindOf: CFConfiguration ] ].
	^ (value isKindOf: CFConfiguration)
		ifTrue: [ { value } ]
		ifFalse: [ #() ]
]

{ #category : 'accessing' }
CFConfigurationBlueprintNodeElement >> configuration: aConfiguration [
	configuration := aConfiguration.
	visitedConfigurations ifNil: [
		visitedConfigurations := IdentitySet new.
		visitedConfigurations add: aConfiguration ].
	self refresh
]

{ #category : 'private - building' }
CFConfigurationBlueprintNodeElement >> createHeaderElement [
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
CFConfigurationBlueprintNodeElement >> createRelationElementFor: aDescription [
	| relationElement heading items children |
	relationElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 9);
		cellSpacing: 6;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		background: (Color white alpha: 0.72);
		border: (BlBorder paint: (Color black alpha: 0.10) width: 1);
		yourself.
	relationElement userData
		at: #cfConfigurationBlueprintOwner
		put: configuration.
	relationElement userData
		at: #cfConfigurationBlueprintDescription
		put: aDescription.
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
	items userData at: #cfConfigurationBlueprintRelationItems put: true.
	children := self configurationChildrenFor: aDescription.
	children isEmpty
		ifTrue: [ items addChild: self newEmptyRelationElement ]
		ifFalse: [ children do: [ :each |
			(visitedConfigurations includes: each) ifFalse: [
				| childVisited |
				childVisited := visitedConfigurations copy.
				childVisited add: each.
				items addChild: (self class
					configuration: each
					visited: childVisited
					selected: selectedConfiguration
					whenSelected: selectionBlock) ] ] ].
	relationElement
		addChild: heading;
		addChild: items.
	^ relationElement
]

{ #category : 'initialization' }
CFConfigurationBlueprintNodeElement >> initialize [
	super initialize.
	self
		hExact: 430;
		vFitContent;
		padding: (BlInsets all: 12);
		cellSpacing: 10;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 14);
		background: (Color r: 0.86 g: 0.91 b: 0.98 alpha: 0.42);
		border: (BlBorder paint: (Color r: 0.26 g: 0.47 b: 0.76 alpha: 0.35) width: 1)
]

{ #category : 'testing' }
CFConfigurationBlueprintNodeElement >> isSelected [
	^ configuration == selectedConfiguration
]

{ #category : 'private - building' }
CFConfigurationBlueprintNodeElement >> newEmptyRelationElement [
	| element |
	element := BrLabel new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 8 left: 10 bottom: 8 right: 10);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 7);
		background: (Color r: 0.18 g: 0.47 b: 0.90 alpha: 0.09);
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFont;
			fontSize: 12;
			foreground: (Color r: 0.13 g: 0.34 b: 0.65 alpha: 0.80);
			yourself);
		text: 'Drop a configuration here';
		yourself.
	element userData at: #cfConfigurationBlueprintEmptyRelationItem put: true.
	^ element
]

{ #category : 'updating' }
CFConfigurationBlueprintNodeElement >> refresh [
	configuration ifNil: [ ^ self ].
	self removeChildren.
	self addChild: self createHeaderElement.
	(configuration magritteDescription
		select: [ :each |
			(each isKindOf: MARelationDescription) and: [ each cfConfigurationEmbedded ] ])
		do: [ :each | self addChild: (self createRelationElementFor: each) ]
]

{ #category : 'accessing' }
CFConfigurationBlueprintNodeElement >> selectedConfiguration: aConfiguration [
	selectedConfiguration := aConfiguration
]

{ #category : 'accessing' }
CFConfigurationBlueprintNodeElement >> visitedConfigurations: aSet [
	visitedConfigurations := aSet
]

{ #category : 'events' }
CFConfigurationBlueprintNodeElement >> whenSelectedDo: aBlock [
	selectionBlock := aBlock
]

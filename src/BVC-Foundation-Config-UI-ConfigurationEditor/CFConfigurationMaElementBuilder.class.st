Class {
	#name : 'CFConfigurationMaElementBuilder',
	#superclass : 'CFMaElementBuilder',
	#instVars : [
		'visitedConfigurations',
		'selectedConfiguration',
		'selectionBlock',
		'expandedConfigurations'
	],
	#category : 'BVC-Foundation-Config-UI-ConfigurationEditor',
	#package : 'BVC-Foundation-Config-UI-ConfigurationEditor'
}

{ #category : 'private - building' }
CFConfigurationMaElementBuilder >> addConfigurationRelationUsing: aDescription [
	| relationElement items value children |
	relationElement := CFConfigurationRelationElement new
		memento: self memento;
		description: aDescription;
		hMatchParent;
		vFitContent;
		padding: BlInsets empty;
		cellSpacing: 0;
		background: Color transparent;
		border: BlBorder empty;
		yourself.
	items := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 5;
		yourself.
	relationElement relationItemsElement: items.
	relationElement addChild: items.
	value := self memento readUsing: aDescription.
	children := value ifNil: [ #() ] ifNotNil: [
		(value isCollection and: [ value isString not ])
			ifTrue: [ value select: [ :each | each isKindOf: CFConfiguration ] ]
			ifFalse: [ (value isKindOf: CFConfiguration)
				ifTrue: [ { value } ]
				ifFalse: [ #() ] ] ].
	children do: [ :each |
		(visitedConfigurations includes: each) ifFalse: [
			| childVisited |
			childVisited := visitedConfigurations copy.
			childVisited add: each.
			items addChild: (CFConfigurationNodeElement
				configuration: each
				visited: childVisited
				expandedConfigurations: expandedConfigurations
				selected: selectedConfiguration
				whenSelected: selectionBlock) ] ].
	self addFieldElement: relationElement using: aDescription
]

{ #category : 'private - building' }
CFConfigurationMaElementBuilder >> addFlowListUsing: aDescription [
	self addConfigurationRelationUsing: aDescription
]

{ #category : 'private - building' }
CFConfigurationMaElementBuilder >> addToOneUsing: aDescription [
	self addConfigurationRelationUsing: aDescription
]

{ #category : 'accessing' }
CFConfigurationMaElementBuilder >> selectedConfiguration: anObject [
	selectedConfiguration := anObject
]

{ #category : 'accessing' }
CFConfigurationMaElementBuilder >> visitedConfigurations: aSet [
	visitedConfigurations := aSet
]

{ #category : 'events' }
CFConfigurationMaElementBuilder >> whenSelectedDo: aBlock [
	selectionBlock := aBlock
]


{ #category : 'accessing' }
CFConfigurationMaElementBuilder >> expandedConfigurations: anIdentitySet [
	expandedConfigurations := anIdentitySet
]

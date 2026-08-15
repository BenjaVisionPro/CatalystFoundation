"I am responsible for the per-form state of tabbed Magritte group presentation. Brick owns tab selection and content switching."

Class {
	#name : 'CFMaTabbedGroupPresentationContext',
	#superclass : 'Object',
	#instVars : [
		'hostElement',
		'labelPresentation',
		'containersByGroup',
		'ungroupedContainer',
		'tabGroup'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'initialization' }
CFMaTabbedGroupPresentationContext >> initialize [
	super initialize.
	containersByGroup := Dictionary new
]

{ #category : 'accessing' }
CFMaTabbedGroupPresentationContext >> hostElement: anElement [
	hostElement := anElement
]

{ #category : 'accessing' }
CFMaTabbedGroupPresentationContext >> labelPresentation: aPresentation [
	labelPresentation := aPresentation
]

{ #category : 'building' }
CFMaTabbedGroupPresentationContext >> addLabel: aLabel field: aFieldElement for: aDescription [
	| aContainer |
	aContainer := self containerForGroup: aDescription group.
	labelPresentation addLabel: aLabel field: aFieldElement to: aContainer
]

{ #category : 'private - building' }
CFMaTabbedGroupPresentationContext >> containerForGroup: aGroup [
	aGroup ifNil: [
		^ ungroupedContainer ifNil: [
			ungroupedContainer := labelPresentation newFieldContainer.
			hostElement addChild: ungroupedContainer.
			ungroupedContainer ] ].

	^ containersByGroup
		at: aGroup
		ifAbsentPut: [ self newTabGroupNamed: aGroup ]
]

{ #category : 'private - building' }
CFMaTabbedGroupPresentationContext >> ensureTabGroup [
	tabGroup ifNotNil: [ ^ tabGroup ].

	tabGroup := BrTabGroup new
		hMatchParent;
		vFitContent;
		aptitude: BrGlamorousTabGroupAptitude new;
		yourself.
	hostElement addChild: tabGroup.
	^ tabGroup
]

{ #category : 'private - building' }
CFMaTabbedGroupPresentationContext >> newTabGroupNamed: aGroup [
	| aContainer aTab |
	aContainer := labelPresentation newFieldContainer.
	aTab := BrTab new
		aptitude: BrGlamorousTabAptitude new;
		label: aGroup asString;
		stencil: [ aContainer ];
		yourself.

	self ensureTabGroup addTab: aTab.
	^ aContainer
]

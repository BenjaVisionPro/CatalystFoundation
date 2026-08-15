"I am responsible for the per-form state of accordion Magritte group presentation. Brick owns expansion; I only compose its header and content."

Class {
	#name : 'CFMaAccordionGroupPresentationContext',
	#superclass : 'Object',
	#instVars : [
		'hostElement',
		'labelPresentation',
		'containersByGroup',
		'ungroupedContainer'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'initialization' }
CFMaAccordionGroupPresentationContext >> initialize [
	super initialize.
	containersByGroup := Dictionary new
]

{ #category : 'accessing' }
CFMaAccordionGroupPresentationContext >> hostElement: anElement [
	hostElement := anElement
]

{ #category : 'accessing' }
CFMaAccordionGroupPresentationContext >> labelPresentation: aPresentation [
	labelPresentation := aPresentation
]

{ #category : 'building' }
CFMaAccordionGroupPresentationContext >> addElement: anElement for: aDescription [
	| aContainer |
	aContainer := self containerForGroup: aDescription group.
	labelPresentation addElement: anElement to: aContainer
]

{ #category : 'building' }
CFMaAccordionGroupPresentationContext >> addLabel: aLabel field: aFieldElement for: aDescription [
	| aContainer |
	aContainer := self containerForGroup: aDescription group.
	labelPresentation addLabel: aLabel field: aFieldElement to: aContainer
]

{ #category : 'private - building' }
CFMaAccordionGroupPresentationContext >> containerForGroup: aGroup [
	aGroup ifNil: [
		^ ungroupedContainer ifNil: [
			ungroupedContainer := labelPresentation newFieldContainer.
			hostElement addChild: ungroupedContainer.
			ungroupedContainer ] ].

	^ containersByGroup
		at: aGroup
		ifAbsentPut: [ self newAccordionGroupNamed: aGroup ]
]

{ #category : 'private - building' }
CFMaAccordionGroupPresentationContext >> newAccordionGroupNamed: aGroup [
	| anAccordion aContainer |
	aContainer := labelPresentation newFieldContainer.
	anAccordion := BrAccordion new
		layout: BlLinearLayout vertical;
		hMatchParent;
		vFitContent;
		aptitude: BrAccordionAptitude new;
		yourself.

	anAccordion
		header: [
			BrButton new
				aptitude: (BrGlamorousButtonWithLabelAptitude new
					foreground: (Color black alpha: 0.68);
					fontSize: 14;
					bold);
				label: aGroup asString;
				margin: (BlInsets top: 10 right: 0 bottom: 4 left: 0);
				hMatchParent;
				action: [ anAccordion toggleExpanded ];
				yourself ];
		content: [ aContainer ];
		expand.

	hostElement addChild: anAccordion.
	^ aContainer
]

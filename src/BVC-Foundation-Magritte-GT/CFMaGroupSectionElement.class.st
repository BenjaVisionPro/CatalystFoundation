"I am responsible for presenting one Magritte description group as a Foundation section. When configured as collapsible I use Brick's standard accordion interaction."

Class {
	#name : 'CFMaGroupSectionElement',
	#superclass : 'BrAccordion',
	#instVars : [
		'groupName',
		'labelLayout',
		'collapsible',
		'groupContentElement'
	],
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'initialization' }
CFMaGroupSectionElement >> initialize [
	super initialize.

	collapsible := false.
	self
		hMatchParent;
		vFitContent;
		aptitude: BrGlamorousAccordionAptitude new;
		expand
]

{ #category : 'accessing' }
CFMaGroupSectionElement >> collapsible: aBoolean [
	collapsible := aBoolean.
	self rebuildHeader
]

{ #category : 'accessing' }
CFMaGroupSectionElement >> groupName: aString [
	groupName := aString.
	self rebuildHeader
]

{ #category : 'accessing' }
CFMaGroupSectionElement >> labelLayout: aLabelLayout [
	labelLayout := aLabelLayout.
	groupContentElement := labelLayout newGroupContentContainer.
	self content: [ groupContentElement ]
]

{ #category : 'building' }
CFMaGroupSectionElement >> addLabel: aLabel field: aFieldElement [
	groupContentElement addChild: aLabel.
	groupContentElement addChild: aFieldElement
]

{ #category : 'private - building' }
CFMaGroupSectionElement >> newCollapsibleHeader [
	^ BrButton new
		aptitude: BrGlamorousAccordionHeaderAptitude new;
		label: groupName asString;
		action: [ self toggleExpanded ];
		yourself
]

{ #category : 'private - building' }
CFMaGroupSectionElement >> newStaticHeader [
	^ BrLabel new
		text: groupName asString;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.68);
			fontSize: 14;
			bold);
		fitContent;
		yourself
]

{ #category : 'private - building' }
CFMaGroupSectionElement >> rebuildHeader [
	| aHeader |
	groupName ifNil: [ ^ self ].

	aHeader := collapsible
		ifTrue: [ self newCollapsibleHeader ]
		ifFalse: [ self newStaticHeader ].

	labelLayout ifNotNil: [
		labelLayout configureGroupLabel: aHeader ].

	self header: [ aHeader ].
	self expand
]

"I am responsible for presenting one Magritte description group as a Foundation section. When configured as collapsible I use Brick's accordion expansion model while keeping one persistent group header."

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
		aptitude: (BrGlamorousAccordionAptitude new
			doNotReplaceHeader);
		expand
]

{ #category : 'accessing' }
CFMaGroupSectionElement >> collapsible: aBoolean [
	collapsible := aBoolean.
	self installHeader
]

{ #category : 'accessing' }
CFMaGroupSectionElement >> groupName: aString [
	groupName := aString.
	self installHeader
]

{ #category : 'accessing' }
CFMaGroupSectionElement >> labelLayout: aLabelLayout [
	labelLayout := aLabelLayout.
	groupContentElement := labelLayout newGroupContentContainer.
	self content: [ groupContentElement ].
	self installHeader
]

{ #category : 'building' }
CFMaGroupSectionElement >> addLabel: aLabel field: aFieldElement [
	groupContentElement addChild: aLabel.
	groupContentElement addChild: aFieldElement
]

{ #category : 'private - building' }
CFMaGroupSectionElement >> installHeader [
	groupName ifNil: [ ^ self ].
	labelLayout ifNil: [ ^ self ].

	self header: [
		| aHeader |
		aHeader := collapsible
			ifTrue: [ self newCollapsibleHeader ]
			ifFalse: [ self newStaticHeader ].
		labelLayout configureGroupLabel: aHeader.
		aHeader ]
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

"I am responsible for presenting one Magritte description group as a Foundation section. I use Brick's BrAccordion lifecycle directly: configure header and content first, then establish expansion state."

Class {
	#name : 'CFMaGroupSectionElement',
	#superclass : 'BrAccordion',
	#instVars : [
		'groupName',
		'labelLayout',
		'collapsible',
		'groupContentElement',
		'isConfigured'
	],
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'initialization' }
CFMaGroupSectionElement >> initialize [
	super initialize.

	collapsible := false.
	isConfigured := false.

	self
		layout: BlLinearLayout vertical;
		hMatchParent;
		vFitContent;
		aptitude: BrAccordionAptitude new
]

{ #category : 'accessing' }
CFMaGroupSectionElement >> collapsible: aBoolean [
	collapsible := aBoolean
]

{ #category : 'accessing' }
CFMaGroupSectionElement >> groupName: aString [
	groupName := aString
]

{ #category : 'accessing' }
CFMaGroupSectionElement >> labelLayout: aLabelLayout [
	labelLayout := aLabelLayout.
	groupContentElement := labelLayout newGroupContentContainer
]

{ #category : 'building' }
CFMaGroupSectionElement >> addLabel: aLabel field: aFieldElement [
	groupContentElement addChild: aLabel.
	groupContentElement addChild: aFieldElement
]

{ #category : 'building' }
CFMaGroupSectionElement >> configure [
	isConfigured ifTrue: [ ^ self ].

	self
		header: [ self newHeader ];
		content: [ groupContentElement ];
		expand.

	isConfigured := true
]

{ #category : 'private - building' }
CFMaGroupSectionElement >> newHeader [
	| aHeader |
	aHeader := collapsible
		ifTrue: [ self newCollapsibleHeader ]
		ifFalse: [ self newStaticHeader ].

	labelLayout configureGroupLabel: aHeader.
	^ aHeader
]

{ #category : 'private - building' }
CFMaGroupSectionElement >> newCollapsibleHeader [
	^ BrButton new
		aptitude: (BrGlamorousButtonWithLabelAptitude new
			foreground: (Color black alpha: 0.68);
			fontSize: 14;
			bold);
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

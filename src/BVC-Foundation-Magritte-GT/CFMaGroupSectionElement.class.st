"I am responsible for presenting one Magritte description group and, when enabled, allowing its fields to be rolled up under the group heading."

Class {
	#name : 'CFMaGroupSectionElement',
	#superclass : 'BrExpander',
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
		layout: BlLinearLayout vertical;
		aptitude: (BrExpanderAptitude new doNotReplaceHeader);
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
CFMaGroupSectionElement >> newGroupHeader [
	| aHeader |
	aHeader := collapsible
		ifTrue: [
			BrButton new
				label: groupName asString;
				aptitude: (BrGlamorousButtonWithLabelAptitude new
					foreground: (Color black alpha: 0.68);
					fontSize: 14;
					bold);
				action: [ :aButton | self toggleExpanded ];
				yourself ]
		ifFalse: [
			BrLabel new
				text: groupName asString;
				aptitude: (BrGlamorousLabelAptitude new
					foreground: (Color black alpha: 0.68);
					fontSize: 14;
					bold);
				fitContent;
				yourself ].

	labelLayout ifNotNil: [
		labelLayout configureGroupLabel: aHeader ].
	^ aHeader
]

{ #category : 'private - building' }
CFMaGroupSectionElement >> rebuildHeader [
	groupName ifNil: [ ^ self ].
	self header: [ self newGroupHeader ]
]

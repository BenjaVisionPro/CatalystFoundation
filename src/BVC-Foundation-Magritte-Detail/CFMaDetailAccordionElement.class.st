Class {
	#name : 'CFMaDetailAccordionElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'accordionCount'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailAccordionElement >> initialize [
	super initialize.
	accordionCount := 0.
	self
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		cellSpacing: 10
]

{ #category : 'adding' }
CFMaDetailAccordionElement >> addGroup: aGroup label: aLabel [
	| anAccordion |
	accordionCount := accordionCount + 1.
	aGroup margin: (BlInsets top: 10).

	anAccordion := BrAccordion new
		layout: BlLinearLayout vertical;
		hMatchParent;
		vFitContent;
		aptitude: BrAccordionAptitude new;
		header: [
			BrButton new
				aptitude: (BrGlamorousButtonWithLabelAptitude new
					foreground: CFMaDetailColours primaryForeground;
					fontSize: 14;
					bold);
				label: aLabel asString;
				hMatchParent;
				vFitContent;
				padding: BlInsets empty;
				margin: (BlInsets left: 14 right: 14);
				action: [ anAccordion toggleExpanded ];
				yourself ];
		content: [ aGroup ];
		yourself.

	accordionCount = 1 ifTrue: [ anAccordion expand ].
	self addChild: anAccordion.
	^ anAccordion
]

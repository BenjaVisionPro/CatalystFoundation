Class {
	#name : 'CFMaDetailAccordionElement',
	#superclass : 'BrVerticalPane',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailAccordionElement >> initialize [
	super initialize.
	self
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		cellSpacing: 10
]

{ #category : 'adding' }
CFMaDetailAccordionElement >> addGroup: aGroup label: aLabel [
	| anAccordion |
	anAccordion := BrAccordion new
		hMatchParent;
		vFitContent;
		aptitude: BrGlamorousAccordionAptitude new;
		header: [
			BrButton new
				aptitude: BrGlamorousAccordionHeaderAptitude new;
				label: aLabel asString;
				action: [ anAccordion toggleExpanded ];
				yourself ];
		content: [ aGroup ];
		yourself.
	self addChild: anAccordion.
	^ anAccordion
]

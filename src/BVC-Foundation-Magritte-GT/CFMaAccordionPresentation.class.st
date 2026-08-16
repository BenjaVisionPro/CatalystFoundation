"I present the current Foundation field styling with Magritte groups as Brick accordions."

Class {
	#name : 'CFMaAccordionPresentation',
	#superclass : 'CFMaPresentation',
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'private - groups' }
CFMaAccordionPresentation >> newGroupNamed: aGroup [
	| anAccordion aContainer |
	aContainer := self newFieldContainer.
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

	self hostElement addChild: anAccordion.
	^ aContainer
]

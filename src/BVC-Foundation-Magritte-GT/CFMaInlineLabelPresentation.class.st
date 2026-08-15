"I am responsible for presenting a Magritte field label above its editor."

Class {
	#name : 'CFMaInlineLabelPresentation',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'building' }
CFMaInlineLabelPresentation >> newFieldContainer [
	^ BrVerticalPane new
		background: Color transparent;
		border: BlBorder empty;
		margin: BlInsets empty;
		cellSpacing: 4;
		hMatchParent;
		vFitContent;
		yourself
]

{ #category : 'building' }
CFMaInlineLabelPresentation >> addLabel: aLabel field: aFieldElement to: aContainer [
	aLabel margin: (BlInsets top: 3 right: 0 bottom: 2 left: 0).
	aFieldElement constraintsDo: [ :c | c horizontal matchParent ].

	aContainer
		addChild: aLabel;
		addChild: aFieldElement
]

"I am responsible for presenting Magritte field labels in a shared column to the left of their editors."

Class {
	#name : 'CFMaLeftLabelPresentation',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'building' }
CFMaLeftLabelPresentation >> newFieldContainer [
	^ BrHorizontalGrid new
		background: Color transparent;
		border: BlBorder empty;
		margin: BlInsets empty;
		cellSpacing: 4;
		columnCount: 2;
		hMatchParent;
		vFitContent;
		yourself
]

{ #category : 'building' }
CFMaLeftLabelPresentation >> addLabel: aLabel field: aFieldElement to: aContainer [
	aLabel
		margin: (BlInsets top: 3 right: 12 bottom: 6 left: 0);
		constraintsDo: [ :c | c grid vertical alignTop ].

	aFieldElement constraintsDo: [ :c |
		c horizontal matchParent.
		c grid horizontal weight: 1 ].

	aContainer
		addChild: aLabel;
		addChild: aFieldElement
]

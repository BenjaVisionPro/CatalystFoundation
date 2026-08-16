"I preserve the prototype's left-label/tabbed rendering as one complete presentation."

Class {
	#name : 'CFMaLeftTabbedPresentation',
	#superclass : 'CFMaTabbedPresentation',
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'private - composition' }
CFMaLeftTabbedPresentation >> newFieldContainer [
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

{ #category : 'private - composition' }
CFMaLeftTabbedPresentation >> addLabel: aLabel field: aFieldElement to: aContainer [
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

{ #category : 'private - composition' }
CFMaLeftTabbedPresentation >> addElement: anElement to: aContainer [
	anElement constraintsDo: [ :c |
		c horizontal matchParent.
		c grid horizontal span: 2 ].
	aContainer addChild: anElement
]

"I am responsible for composing Foundation Magritte labels in a shared column to the left of their fields."

Class {
	#name : 'CFMaLeftLabelLayout',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Layout',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Layout'
}

{ #category : 'building' }
CFMaLeftLabelLayout >> newFormContainer [
	| aGrid |
	aGrid := BrHorizontalGrid new.
	aGrid magritte
		beLabelContainer;
		beFieldContainer;
		beToolbarContainer.
	aGrid
		cellSpacing: 4;
		columnCount: 2;
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 14 right: 16 bottom: 14 left: 16).
	^ aGrid
]

{ #category : 'configuration' }
CFMaLeftLabelLayout >> configureLabel: aLabel field: aFieldElement [
	aLabel
		margin: (BlInsets top: 3 right: 12 bottom: 6 left: 0);
		constraintsDo: [ :c | c grid vertical alignTop ].

	aFieldElement constraintsDo: [ :c |
		c horizontal matchParent.
		c grid horizontal weight: 1 ].
]


{ #category : 'configuration' }
CFMaLeftLabelLayout >> configureGroupLabel: aLabel [
	aLabel
		margin: (BlInsets top: 10 right: 0 bottom: 4 left: 0);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c grid horizontal span: 2 ]
]

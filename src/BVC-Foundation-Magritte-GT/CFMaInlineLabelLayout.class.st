"I am responsible for composing Foundation Magritte labels above their fields so each editor can use the full form width."

Class {
	#name : 'CFMaInlineLabelLayout',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Layout',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Layout'
}

{ #category : 'building' }
CFMaInlineLabelLayout >> newFormContainer [
	| aContainer |
	aContainer := BrVerticalPane new
		background: Color transparent;
		border: BlBorder empty;
		margin: BlInsets empty;
		cellSpacing: 4;
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 14 right: 16 bottom: 14 left: 16).

	aContainer magritte
		beLabelContainer;
		beFieldContainer;
		beToolbarContainer.

	^ aContainer
]

{ #category : 'configuration' }
CFMaInlineLabelLayout >> configureLabel: aLabel field: aFieldElement [
	aLabel
		margin: (BlInsets top: 3 right: 0 bottom: 2 left: 0).

	aFieldElement constraintsDo: [ :c |
		c horizontal matchParent ].
]


{ #category : 'configuration' }
CFMaInlineLabelLayout >> configureGroupLabel: aLabel [
	aLabel
		margin: (BlInsets top: 10 right: 0 bottom: 4 left: 0);
		constraintsDo: [ :c | c horizontal matchParent ]
]


{ #category : 'building' }
CFMaInlineLabelLayout >> newGroupContentContainer [
	^ BrVerticalPane new
		background: Color transparent;
		border: BlBorder empty;
		margin: BlInsets empty;
		cellSpacing: 4;
		hMatchParent;
		vFitContent;
		yourself
]


{ #category : 'configuration' }
CFMaInlineLabelLayout >> configureGroupSection: aGroupSection [
	aGroupSection constraintsDo: [ :c | c horizontal matchParent ]
]

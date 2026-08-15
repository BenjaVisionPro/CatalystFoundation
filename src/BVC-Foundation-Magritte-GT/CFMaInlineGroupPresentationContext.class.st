"I am responsible for the per-form state of inline Magritte group presentation."

Class {
	#name : 'CFMaInlineGroupPresentationContext',
	#superclass : 'Object',
	#instVars : [
		'hostElement',
		'labelPresentation',
		'containersByGroup',
		'ungroupedContainer'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'initialization' }
CFMaInlineGroupPresentationContext >> initialize [
	super initialize.
	containersByGroup := Dictionary new
]

{ #category : 'accessing' }
CFMaInlineGroupPresentationContext >> hostElement: anElement [
	hostElement := anElement
]

{ #category : 'accessing' }
CFMaInlineGroupPresentationContext >> labelPresentation: aPresentation [
	labelPresentation := aPresentation
]

{ #category : 'building' }
CFMaInlineGroupPresentationContext >> addLabel: aLabel field: aFieldElement for: aDescription [
	| aContainer |
	aContainer := self containerForGroup: aDescription group.
	labelPresentation addLabel: aLabel field: aFieldElement to: aContainer
]

{ #category : 'private - building' }
CFMaInlineGroupPresentationContext >> containerForGroup: aGroup [
	aGroup ifNil: [
		^ ungroupedContainer ifNil: [
			ungroupedContainer := labelPresentation newFieldContainer.
			hostElement addChild: ungroupedContainer.
			ungroupedContainer ] ].

	^ containersByGroup
		at: aGroup
		ifAbsentPut: [ self newGroupNamed: aGroup ]
]

{ #category : 'private - building' }
CFMaInlineGroupPresentationContext >> newGroupNamed: aGroup [
	| aSection aHeading aContainer |
	aHeading := BrLabel new
		text: aGroup asString;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.68);
			fontSize: 14;
			bold);
		fitContent;
		margin: (BlInsets top: 10 right: 0 bottom: 4 left: 0);
		yourself.

	aContainer := labelPresentation newFieldContainer.
	aSection := BrVerticalPane new
		hMatchParent;
		vFitContent;
		addChild: aHeading;
		addChild: aContainer;
		yourself.

	hostElement addChild: aSection.
	^ aContainer
]

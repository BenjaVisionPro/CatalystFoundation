Class {
	#name : 'CFMagritteBuilderUtility',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'elements' }
CFMagritteBuilderUtility class >> newFieldLabelWithSpace: aSpaceNumber using: aDescription [
	| aText labelAptitude |
	aText := aDescription label asRopedText.

	labelAptitude := aDescription labelAptitude
			ifNil: [ BrGlamorousLabelAptitude new
					foreground: BrGlamorousColors disabledButtonTextColor ]
			ifNotNil: #value.

	^ BrLabel new
		id: (GtMagritteFieldLabelId new description: aDescription);
		text: aText;
		aptitude: labelAptitude;
		fitContent;
		margin: (BlInsets
				top: 2
				right: (aSpaceNumber ifNil: [ GtMagritteBuilderUtility defaultSpaceNumber ])
				bottom: (aSpaceNumber ifNil: [ GtMagritteBuilderUtility defaultSpaceNumber ])
				left: 0);
		constraintsDo: [ :c | c grid vertical alignTop ];
		when: BlClickEvent
			do: [ :anEvent | 
				anEvent modifiers isAlt
					ifTrue: [ anEvent consumed: true.
						anEvent target phlow spawnObject: aDescription ] ]
]

{ #category : 'elements' }
CFMagritteBuilderUtility class >> newFormContainerFor: aMemento [
	^ BrVerticalPane new
		in: [ :aPane | 
			aPane magritte
				beFieldContainer;
				beToolbarContainer ];
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 12);
		cellSpacing: 8;
		background: (Color black alpha: 0.05);
		yourself
]

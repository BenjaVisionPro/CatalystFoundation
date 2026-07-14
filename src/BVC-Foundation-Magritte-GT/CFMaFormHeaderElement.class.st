Class {
	#name : 'CFMaFormHeaderElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'memento',
		'toggleElement',
		'iconContainer',
		'primaryFieldsContainer',
		'classLinkElement',
		'contentElement',
		'expanded'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'building' }
CFMaFormHeaderElement >> addHeaderField: aFieldElement using: aDescription [
	(aDescription handlesSelector: #defaultIcon)
		ifTrue: [
			iconContainer removeChildren.
			iconContainer addChild: aFieldElement.
			^ self ].

	((aDescription handlesSelector: #label)
		or: [ aDescription handlesSelector: #identifier ])
		ifTrue: [
			primaryFieldsContainer addChild: aFieldElement.
			^ self ]
]

{ #category : 'accessing' }
CFMaFormHeaderElement >> contentElement: anElement [
	contentElement := anElement
]

{ #category : 'initialization' }
CFMaFormHeaderElement >> initialize [
	super initialize.
	expanded := true.

	toggleElement := BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.62));
		text: '▾';
		when: BlClickEvent do: [ :anEvent |
			self toggleExpanded.
			anEvent consumed: true ];
		yourself.

	iconContainer := BrFrame new
		hExact: 56;
		vExact: 56;
		layout: BlFrameLayout new;
		yourself.

	primaryFieldsContainer := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 1;
		yourself.

	classLinkElement := BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.42));
		yourself.

	self
		hMatchParent;
		vFitContent;
		cellSpacing: 7;
		padding: (BlInsets top: 9 right: 11 bottom: 8 left: 8);
		addChild: toggleElement as: #toggle;
		addChild: iconContainer as: #icon;
		addChild: primaryFieldsContainer as: #primaryFields;
		addChild: classLinkElement as: #classLink
]

{ #category : 'accessing' }
CFMaFormHeaderElement >> memento: aMemento [
	memento := aMemento.
	classLinkElement
		text: aMemento model class name;
		when: BlClickEvent do: [ :anEvent |
			anEvent currentTarget phlow spawnObject: aMemento model class.
			anEvent consumed: true ]
]

{ #category : 'private' }
CFMaFormHeaderElement >> toggleExpanded [
	expanded := expanded not.
	contentElement ifNotNil: [
		contentElement visibility: (expanded
			ifTrue: [ BlVisibility visible ]
			ifFalse: [ BlVisibility gone ]) ].
	toggleElement text: (expanded ifTrue: [ '▾' ] ifFalse: [ '▸' ])
]

{ #category : 'accessing' }
CFMaFormHeaderElement >> expanded [
	^ expanded
]

{ #category : 'accessing' }
CFMaFormHeaderElement >> expanded: aBoolean [
	expanded = aBoolean ifTrue: [ ^ self ].
	expanded := aBoolean.
	contentElement ifNotNil: [
		contentElement visibility: (expanded
			ifTrue: [ BlVisibility visible ]
			ifFalse: [ BlVisibility gone ]) ].
	toggleElement text: (expanded ifTrue: [ '▾' ] ifFalse: [ '▸' ])
]

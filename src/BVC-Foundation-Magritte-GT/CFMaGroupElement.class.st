Class {
	#name : 'CFMaGroupElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'headerElement',
		'bodyElement',
		'toggleElement',
		'expanded'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'accessing' }
CFMaGroupElement >> bodyElement [
	^ bodyElement
]

{ #category : 'initialization' }
CFMaGroupElement >> initialize [
	super initialize.
	expanded := true.

	toggleElement := BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.55));
		text: '▾';
		yourself.

	headerElement := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 5;
		padding: (BlInsets top: 4 right: 0 bottom: 4 left: 0);
		when: BlClickEvent do: [ :anEvent |
			self toggleExpanded.
			anEvent consumed: true ];
		yourself.

	bodyElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 7;
		yourself.

	self
		hMatchParent;
		vFitContent;
		cellSpacing: 2;
		addChild: headerElement as: #header;
		addChild: bodyElement as: #body
]

{ #category : 'accessing' }
CFMaGroupElement >> label: aString [
	headerElement removeChildren.
	headerElement
		addChild: toggleElement as: #toggle;
		addChild: (BrLabel new
			fitContent;
			aptitude: (BrGlamorousLabelAptitude new
				foreground: (Color black alpha: 0.48));
			text: aString asString asUppercase;
			yourself) as: #label
]

{ #category : 'private' }
CFMaGroupElement >> toggleExpanded [
	expanded := expanded not.
	bodyElement visibility: (expanded
		ifTrue: [ BlVisibility visible ]
		ifFalse: [ BlVisibility gone ]).
	toggleElement text: (expanded ifTrue: [ '▾' ] ifFalse: [ '▸' ])
]

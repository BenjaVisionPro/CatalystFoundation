Class {
	#name : 'CFMaDetailGroupElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'card',
		'groups'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'adding' }
CFMaDetailGroupElement >> addGroup: aGroup [
	groups addChild: aGroup
]

{ #category : 'accessing' }
CFMaDetailGroupElement >> group: aGroup [
	aGroup ifNil: [ ^ self ].
	self addChildFirst: (BrLabel new
		text: aGroup asString;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: CFMaDetailColours primaryForeground;
			fontSize: 14;
			bold);
		fitContent;
		margin: (BlInsets top: 22 right: 14 bottom: 10 left: 14);
		yourself)
]

{ #category : 'initialization' }
CFMaDetailGroupElement >> initialize [
	super initialize.
	card := CFMaDetailGroupCardElement new
		visibility: BlVisibility gone;
		margin: (BlInsets left: 6 right: 6);
		yourself.
	groups := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 10;
		margin: BlInsets empty;
		yourself.
	self
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		cellSpacing: 0;
		addChild: card;
		addChild: groups
]

{ #category : 'accessing' }
CFMaDetailGroupElement >> rows [
	card visibility: BlVisibility visible.
	^ card
]

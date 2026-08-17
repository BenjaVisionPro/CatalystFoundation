Class {
	#name : 'CFMaSettingsSectionElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'cards'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'initialization' }
CFMaSettingsSectionElement >> initialize [
	super initialize.
	cards := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 10;
		yourself.
	self
		hMatchParent;
		vFitContent;
		margin: (BlInsets left: 6 right: 6);
		addChild: cards
]

{ #category : 'adding' }
CFMaSettingsSectionElement >> addCard: aCard [
	cards addChild: aCard
]

{ #category : 'accessing' }
CFMaSettingsSectionElement >> heading: aLabel [
	self addChildFirst: aLabel
]

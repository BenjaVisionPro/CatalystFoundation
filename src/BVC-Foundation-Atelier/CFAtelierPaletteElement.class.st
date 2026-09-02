"I present one configured Atelier palette as a draggable source of materialized candidate objects.

I do not choose a target or an operation. Each drag lift asks its palette item to materialize exactly once and puts that candidate object on the ordinary Bloc drag item. Target interaction can then assess that same identity through an Atelier operation."
Class {
	#name : 'CFAtelierPaletteElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'palette',
		'itemsElement'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'initialization' }
CFAtelierPaletteElement >> initialize [
	super initialize.
	self
		hExact: 220;
		vFitContent;
		padding: (BlInsets all: 10);
		cellSpacing: 8.
	self addChild: (BrLabel new
		fitContent;
		aptitude: BrGlamorousLabelAptitude new;
		text: 'Palette';
		yourself).
	itemsElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 4;
		yourself.
	self addChild: itemsElement
]

{ #category : 'accessing' }
CFAtelierPaletteElement >> palette [
	^ palette
]

{ #category : 'accessing' }
CFAtelierPaletteElement >> palette: anAtelierPalette [
	palette := anAtelierPalette.
	self refresh
]

{ #category : 'updating' }
CFAtelierPaletteElement >> refresh [
	itemsElement ifNil: [ ^ self ].
	itemsElement removeChildren.
	palette ifNil: [ ^ self ].
	palette items do: [ :anItem |
		itemsElement addChild: (self newItemElementFor: anItem) ]
]

{ #category : 'private - building' }
CFAtelierPaletteElement >> newItemElementFor: anItem [
	| aRow |
	aRow := BrLabel new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 7 left: 8 bottom: 7 right: 8);
		aptitude: BrGlamorousLabelAptitude new;
		text: anItem label;
		yourself.
	aRow addEventHandler: (BlDragHandler new
		liftItem: [ :aSourceElement |
			self dragItemFor: anItem sourceElement: aSourceElement ];
		yourself).
	^ aRow
]

{ #category : 'interaction' }
CFAtelierPaletteElement >> dragItemFor: anItem sourceElement: aSourceElement [
	| aCandidate |
	aCandidate := anItem materialize.
	^ BlDragItem new
		sourceElement: aSourceElement;
		domainObject: aCandidate;
		stencil: [ :aDragItem |
			BrLabel new
				fitContent;
				padding: (BlInsets all: 7);
				aptitude: BrGlamorousLabelAptitude new;
				text: anItem label;
				yourself ];
		yourself
]

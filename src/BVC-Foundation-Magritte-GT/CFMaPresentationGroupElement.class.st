"I am Foundation's default presentation-side realization of one semantic Magritte group. I preserve encounter order between ordinary content runs and nested presentations."

Class {
	#name : 'CFMaPresentationGroupElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'composition',
		'currentContentContainer'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'initialization' }
CFMaPresentationGroupElement >> initialize [
	super initialize.
	currentContentContainer := nil.
	composition := BrVerticalPane new
		background: Color transparent;
		border: BlBorder empty;
		margin: BlInsets empty;
		cellSpacing: 4;
		hMatchParent;
		vFitContent;
		yourself.
	self
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		cellSpacing: 0;
		addChild: composition
]

{ #category : 'composition' }
CFMaPresentationGroupElement >> addContent: anElement [
	self currentContentContainer addChild: anElement.
	^ anElement
]

{ #category : 'composition' }
CFMaPresentationGroupElement >> addNestedPresentationElement: anElement [
	currentContentContainer := nil.
	composition addChild: anElement.
	^ anElement
]

{ #category : 'private - composition' }
CFMaPresentationGroupElement >> currentContentContainer [
	currentContentContainer ifNotNil: [ ^ currentContentContainer ].
	currentContentContainer := BrVerticalPane new
		background: Color transparent;
		border: BlBorder empty;
		margin: BlInsets empty;
		cellSpacing: 4;
		hMatchParent;
		vFitContent;
		yourself.
	composition addChild: currentContentContainer.
	^ currentContentContainer
]

{ #category : 'accessing' }
CFMaPresentationGroupElement >> group: aGroup [
	aGroup ifNil: [ ^ self ].
	self addChildFirst: (BrLabel new
		text: aGroup asString;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.68);
			fontSize: 14;
			bold);
		fitContent;
		margin: (BlInsets top: 10 right: 0 bottom: 4 left: 0);
		yourself)
]

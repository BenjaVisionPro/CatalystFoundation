Class {
	#name : 'CFMaDetailButtonBarElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'bar',
		'content',
		'groupElements'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'adding' }
CFMaDetailButtonBarElement >> addGroup: aGroup label: aLabel [
	| aToggle |
	aGroup
		visibility: BlVisibility gone;
		margin: (BlInsets top: self groupSpacing).
	content addChild: aGroup.
	groupElements add: aGroup.

	aToggle := self newToggleLabel: aLabel group: aGroup.
	bar addToggle: aToggle.
	groupElements size = 1 ifTrue: [ aToggle activate ]
]

{ #category : 'geometry' }
CFMaDetailButtonBarElement >> groupSpacing [
	^ 10
]

{ #category : 'initialization' }
CFMaDetailButtonBarElement >> initialize [
	super initialize.
	groupElements := OrderedCollection new.
	bar := BrToggleGroup new
		hMatchParent;
		vExact: 32;
		layout: (BlLinearLayout horizontal cellSpacing: 0);
		padding: (BlInsets all: 2);
		margin: (BlInsets left: 6 right: 6);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 9);
		background: (Color black alpha: 0.08);
		yourself.
	content := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		yourself.
	self
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		cellSpacing: 0;
		addChild: bar;
		addChild: content
]

{ #category : 'private' }
CFMaDetailButtonBarElement >> newToggleLabel: aLabel group: aGroup [
	| aToggle aStyle |
	aStyle := BrToggleAptitude new
		default: [ :aState |
			aState
				background: Color transparent;
				geometry: (BlRoundedRectangleGeometry cornerRadius: 7) ];
		activated: [ :aState |
			aState background: CFMaDetailColours highlight ];
		yourself.
	aToggle := BrToggle new
		aptitude: BrGlamorousTextLabelAptitude new + BrGlamorousToggleLayoutAptitude new + aStyle;
		label: (aLabel asString asRopedText foreground: CFMaDetailColours primaryForeground);
		hMatchParent;
		vExact: 28;
		padding: (BlInsets left: 12 right: 12);
		constraintsDo: [ :c | c linear weight: 1 ];
		yourself.
	aToggle
		when: BrToggleActivatedEvent
		do: [ :anEvent |
			aToggle label: (aLabel asString asRopedText foreground: Color white).
			self showGroup: aGroup ];
		when: BrToggleDeactivatedEvent
		do: [ :anEvent |
			aToggle label: (aLabel asString asRopedText foreground: CFMaDetailColours primaryForeground) ].
	^ aToggle
]

{ #category : 'private' }
CFMaDetailButtonBarElement >> showGroup: aGroup [
	groupElements do: [ :each |
		each visibility: (each == aGroup
			ifTrue: [ BlVisibility visible ]
			ifFalse: [ BlVisibility gone ]) ]
]

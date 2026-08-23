Class {
	#name : 'CFMaDetailButtonBarElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'bar',
		'content',
		'groupElements',
		'configuration'
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

	aToggle := configuration isIconOnly
		ifTrue: [ self newIconToggle: (configuration iconFor: aLabel) group: aGroup ]
		ifFalse: [ self newLabelToggle: aLabel group: aGroup ].
	bar addToggle: aToggle.
	groupElements size = 1 ifTrue: [ aToggle activate ]
]

{ #category : 'accessing' }
CFMaDetailButtonBarElement >> configuration: aConfiguration [
	configuration := aConfiguration
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
		vExact: 24;
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
CFMaDetailButtonBarElement >> newIconToggle: anIcon group: aGroup [
	| aToggle aStyle |
	anIcon size: 16 @ 16.
	aStyle := self toggleStyle.
	aToggle := BrToggle new
		aptitude: BrGlamorousButtonIconAptitude new + BrGlamorousToggleLayoutAptitude new + aStyle;
		icon: anIcon;
		hMatchParent;
		vExact: 20;
		constraintsDo: [ :c | c linear weight: 1 ];
		yourself.
	aToggle when: BrToggleActivatedEvent do: [ :anEvent | self showGroup: aGroup ].
	^ aToggle
]

{ #category : 'private' }
CFMaDetailButtonBarElement >> newLabelToggle: aLabel group: aGroup [
	| aToggle aStyle |
	aStyle := self toggleStyle.
	aToggle := BrToggle new
		aptitude: BrGlamorousTextLabelAptitude new + BrGlamorousToggleLayoutAptitude new + aStyle;
		label: (aLabel asString asRopedText foreground: CFMaDetailColours primaryForeground);
		hMatchParent;
		vExact: 20;
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
CFMaDetailButtonBarElement >> toggleStyle [
	^ BrToggleAptitude new
		default: [ :aState |
			aState
				background: Color transparent;
				geometry: (BlRoundedRectangleGeometry cornerRadius: 7) ];
		activated: [ :aState |
			aState background: CFMaDetailColours highlight ];
		yourself
]

{ #category : 'private' }
CFMaDetailButtonBarElement >> showGroup: aGroup [
	groupElements do: [ :each |
		each visibility: (each == aGroup
			ifTrue: [ BlVisibility visible ]
			ifFalse: [ BlVisibility gone ]) ]
]

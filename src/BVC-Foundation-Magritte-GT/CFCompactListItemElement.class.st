Class {
	#name : 'CFCompactListItemElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'model',
		'description',
		'memento',
		'iconContainer',
		'titleElement',
		'commentElement',
		'textContainer'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'instance creation' }
CFCompactListItemElement class >> model: anObject description: aDescription [
	^ self new
		model: anObject;
		description: aDescription;
		yourself
]

{ #category : 'accessing' }
CFCompactListItemElement >> description [
	^ description
]

{ #category : 'accessing' }
CFCompactListItemElement >> description: aDescription [
	description := aDescription.
	memento := nil.
	self updateFromModel
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> iconDescription [
	^ self itemDescriptionAt: 1
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> iconValue [
	^ self valueForDescription: self iconDescription ifAbsent: [ #inspect ]
]

{ #category : 'initialization' }
CFCompactListItemElement >> initialize [
	super initialize.

	self
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 4 right: 8 bottom: 4 left: 8);
		cellSpacing: 8.

	iconContainer := BrFrame new
		size: 20 @ 20;
		margin: (BlInsets top: 2 right: 0 bottom: 0 left: 0);
		yourself.

	titleElement := BrLabel new
		aptitude: BrGlamorousLabelAptitude new;
		hMatchParent;
		vFitContent;
		yourself.

	commentElement := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.45));
		hMatchParent;
		vFitContent;
		yourself.

	textContainer := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 1;
		addChild: titleElement;
		addChild: commentElement;
		yourself.

	self
		addAptitude: BrGlamorousListItemAptitude new;
		addChild: iconContainer;
		addChild: textContainer
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> itemDescriptionAt: anIndex [
	(description isNil or: [ description children size < anIndex ])
		ifTrue: [ ^ nil ].
	^ description children at: anIndex
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> itemMemento [
	^ memento ifNil: [
		memento := GtMagritteMemento
			model: self model
			description: self description ]
]

{ #category : 'accessing' }
CFCompactListItemElement >> model [
	^ model
]

{ #category : 'accessing' }
CFCompactListItemElement >> model: anObject [
	model := anObject.
	memento := nil.
	self updateFromModel
]

{ #category : 'private - instance creation' }
CFCompactListItemElement >> newIconElementFor: anIconValue [
	| anIcon |
	anIcon := anIconValue.
	anIcon isNil ifTrue: [ anIcon := #inspect ].

	anIcon isSymbol ifTrue: [
		^ [ ((BrGlamorousVectorIcons classSide includesSelector: anIcon)
			ifTrue: [ BrGlamorousVectorIcons perform: anIcon ]
			ifFalse: [ BrGlamorousVectorIcons inspect ]) asElement ]
			on: Error
			do: [ :ignored | BrGlamorousVectorIcons inspect asElement ] ].

	^ [ anIcon asElement ]
		on: Error
		do: [ :ignored |
			BrLabel new
				aptitude: BrGlamorousLabelAptitude new;
				text: '•' asRopedText;
				fitContent;
				yourself ]
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> titleDescription [
	^ self itemDescriptionAt: 2
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> titleValue [
	^ self
		valueForDescription: self titleDescription
		ifAbsent: [ self model ifNil: [ '' ] ifNotNil: [ :anObject | anObject displayString ] ]
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> commentDescription [
	^ self itemDescriptionAt: 3
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> commentValue [
	^ self valueForDescription: self commentDescription ifAbsent: [ nil ]
]

{ #category : 'private - updating' }
CFCompactListItemElement >> updateFromModel [
	| aTitle aComment anIconElement |
	(model isNil or: [ description isNil ]) ifTrue: [ ^ self ].

	aTitle := self titleValue.
	aComment := self commentValue.
	anIconElement := self newIconElementFor: self iconValue.

	iconContainer removeChildren.
	iconContainer addChild: anIconElement.

	titleElement text: (aTitle ifNil: [ '' ]) asString asRopedText.
	commentElement text: (aComment ifNil: [ '' ]) asString asRopedText.
	commentElement visibility: ((aComment isNil or: [ aComment asString isEmpty ])
		ifTrue: [ BlVisibility gone ]
		ifFalse: [ BlVisibility visible ])
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> valueForDescription: aDescription ifAbsent: anAbsentBlock [
	aDescription ifNil: [ ^ anAbsentBlock value ].
	^ self itemMemento readUsing: aDescription
]

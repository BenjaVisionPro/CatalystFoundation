Class {
	#name : 'CFCompactListItemElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'model',
		'iconContainer',
		'titleElement',
		'commentElement',
		'textContainer'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'private - accessing' }
CFCompactListItemElement >> compactDescription [
	| anObject |
	anObject := self itemObject.
	(anObject notNil and: [ anObject respondsTo: #compactListItemDescription ])
		ifTrue: [ ^ anObject compactListItemDescription ].
	^ Object new compactListItemDescription
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> descriptionForRole: aRole [
	| aDescription |
	aDescription := self compactDescription.
	(aDescription respondsTo: #children) ifFalse: [ ^ nil ].
	^ aDescription children
		detect: [ :each |
			(each respondsTo: #propertyAt:ifAbsent:)
				and: [ (each propertyAt: #cfCompactListItemRole ifAbsent: [ nil ]) = aRole ] ]
		ifNone: [ nil ]
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> iconValue [
	^ self valueForRole: #icon ifAbsent: [ #inspect ]
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
		addChild: iconContainer;
		addChild: textContainer
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> itemObject [
	model ifNil: [ ^ nil ].
	(model respondsTo: #object) ifTrue: [ ^ model object ].
	^ model
]

{ #category : 'accessing' }
CFCompactListItemElement >> model [
	^ model
]

{ #category : 'accessing' }
CFCompactListItemElement >> model: anObject [
	model := anObject.
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

{ #category : 'private - updating' }
CFCompactListItemElement >> updateFromModel [
	| aTitle aComment anIconElement |
	model ifNil: [ ^ self ].

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
CFCompactListItemElement >> titleValue [
	^ self valueForRole: #title ifAbsent: [
		self itemObject ifNil: [ '' ] ifNotNil: [ :anObject | anObject displayString ] ]
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> commentValue [
	^ self valueForRole: #comment ifAbsent: [ nil ]
]

{ #category : 'private - accessing' }
CFCompactListItemElement >> valueForRole: aRole ifAbsent: anAbsentBlock [
	| anObject aDescription |
	anObject := self itemObject.
	anObject ifNil: [ ^ anAbsentBlock value ].
	aDescription := self descriptionForRole: aRole.
	aDescription ifNil: [ ^ anAbsentBlock value ].
	^ [ anObject readUsing: aDescription ]
		on: Error
		do: [ :ignored | anAbsentBlock value ]
]

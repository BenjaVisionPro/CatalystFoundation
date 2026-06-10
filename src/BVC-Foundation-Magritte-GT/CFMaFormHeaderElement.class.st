Class {
	#name : 'CFMaFormHeaderElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'memento',
		'titleElement',
		'metadataElement'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'accessing' }
CFMaFormHeaderElement >> headerMetadataText [
	| anObject |
	anObject := self inspectedObject.
	anObject ifNil: [ ^ 'Catalyst Foundation form' ].

	^ anObject class name
]

{ #category : 'accessing' }
CFMaFormHeaderElement >> headerTitleText [
	| anObject |
	anObject := self inspectedObject.
	anObject ifNil: [ ^ 'Form' ].

	^ anObject gtDisplayText asString
]

{ #category : 'initialization' }
CFMaFormHeaderElement >> initialize [
	super initialize.

	titleElement := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.9));
		margin: (BlInsets bottom: 2);
		fitContent;
		yourself.

	metadataElement := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.55));
		fitContent;
		yourself.

	self
		padding: (BlInsets all: 14);
		cellSpacing: 2;
		background: (Color black alpha: 0.02);
		hMatchParent;
		vFitContent.

	self
		addChild: titleElement as: #title;
		addChild: metadataElement as: #metadata.

	self updateFromMemento
]

{ #category : 'accessing' }
CFMaFormHeaderElement >> inspectedObject [
	memento ifNil: [ ^ nil ].
	^ memento model
]

{ #category : 'accessing' }
CFMaFormHeaderElement >> memento [
	^ memento
]

{ #category : 'accessing' }
CFMaFormHeaderElement >> memento: aMemento [
	memento := aMemento.
	self updateFromMemento
]

{ #category : 'updating' }
CFMaFormHeaderElement >> updateFromMemento [
	titleElement ifNil: [ ^ self ].
	titleElement text: self headerTitleText.
	metadataElement text: self headerMetadataText
]

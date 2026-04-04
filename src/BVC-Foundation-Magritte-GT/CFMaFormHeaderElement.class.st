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
	| anObject anIdentifier aMetadata |
	anObject := self inspectedObject.
	anObject ifNil: [ ^ 'Catalyst Foundation form' ].

	aMetadata := anObject class name.
	anIdentifier := (anObject respondsTo: #identifier)
		ifTrue: [ anObject perform: #identifier ]
		ifFalse: [ nil ].
	anIdentifier ifNotNil: [
		aMetadata := aMetadata , ' · ' , anIdentifier asString ].

	^ aMetadata
]

{ #category : 'accessing' }
CFMaFormHeaderElement >> headerTitleText [
	| anObject aTitle |
	anObject := self inspectedObject.
	anObject ifNil: [ ^ 'Form' ].

	aTitle := (anObject respondsTo: #label)
		ifTrue: [ anObject perform: #label ]
		ifFalse: [ nil ].
	(aTitle isNil or: [ aTitle asString isEmpty ])
		ifTrue: [ aTitle := anObject class name ].

	^ aTitle asString
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
	(memento respondsTo: #model)
		ifTrue: [ ^ memento perform: #model ].
	(memento respondsTo: #object)
		ifTrue: [ ^ memento perform: #object ].
	^ nil
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

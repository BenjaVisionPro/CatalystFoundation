Class {
	#name : 'CFCompactObjectElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'object',
		'memento',
		'iconContainer',
		'titleElement'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'private - accessing' }
CFCompactObjectElement >> displayTitleFor: aValue [
	| aString |
	aString := aValue
		ifNil: [ '' ]
		ifNotNil: [ aValue asString ].
	aString isEmpty ifFalse: [ ^ aString ].
	object ifNil: [ ^ '' ].
	^ object gtDisplayText asString
]

{ #category : 'accessing' }
CFCompactObjectElement >> displayedObject [
	^ object
]

{ #category : 'accessing' }
CFCompactObjectElement >> iconContainer [
	^ iconContainer
]

{ #category : 'initialization' }
CFCompactObjectElement >> initialize [
	super initialize.

	iconContainer := BrFrame new
		hExact: 20;
		vExact: 20;
		layout: BlFrameLayout new;
		yourself.
	titleElement := BrLabel new
		hMatchParent;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFont;
			foreground: (Color black alpha: 0.88);
			yourself);
		yourself.

	self
		hMatchParent;
		vFitContent;
		cellSpacing: 8;
		padding: (BlInsets top: 4 left: 6 bottom: 4 right: 6);
		layout: BlLinearLayout horizontal alignCenterLeft;
		addChild: iconContainer as: #icon;
		addChild: titleElement as: #title;
		yourself
]

{ #category : 'accessing' }
CFCompactObjectElement >> memento [
	^ memento
]

{ #category : 'accessing' }
CFCompactObjectElement >> memento: aMemento [
	memento := aMemento.
	object := aMemento ifNil: [ nil ] ifNotNil: #model.
	self refresh.
	self observeMementoLabel
]

{ #category : 'accessing' }
CFCompactObjectElement >> object [
	^ object
]

{ #category : 'accessing' }
CFCompactObjectElement >> object: anObject [
	object := anObject.
	memento := nil.
	self refresh
]

{ #category : 'private - updating' }
CFCompactObjectElement >> observeMementoLabel [
	| aDescription |
	memento ifNil: [ ^ self ].
	aDescription := self titleDescriptionInMemento.
	aDescription ifNil: [ ^ self ].

	self withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theElement :aSink |
				self updateTitleFromValue: aSink value currentValue ].
		(memento readObservableValueUsing: aDescription)
			observe: anElementSink ]
]

{ #category : 'updating' }
CFCompactObjectElement >> refresh [
	self
		refreshIcon;
		refreshTitle
]

{ #category : 'private - updating' }
CFCompactObjectElement >> refreshIcon [
	| anIconElement |
	iconContainer removeChildren.
	(object notNil and: [ object respondsTo: #icon ])
		ifFalse: [ iconContainer visibility: BlVisibility gone.
			^ self ].
	iconContainer visibility: BlVisibility visible.
	anIconElement := object icon asElement
		size: 16 @ 16;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		yourself.
	iconContainer addChild: anIconElement
]

{ #category : 'private - updating' }
CFCompactObjectElement >> refreshTitle [
	| aValue |
	aValue := memento
		ifNil: [ self titleValueFromObject ]
		ifNotNil: [ :aMemento |
			self titleDescriptionInMemento
				ifNil: [ self titleValueFromObject ]
				ifNotNil: [ :aDescription | aMemento readUsing: aDescription ] ].
	self updateTitleFromValue: aValue
]

{ #category : 'accessing' }
CFCompactObjectElement >> titleElement [
	^ titleElement
]

{ #category : 'private - accessing' }
CFCompactObjectElement >> titleDescriptionInMemento [
	memento ifNil: [ ^ nil ].
	^ memento magritteDescription
		detect: [ :each | each handlesSelector: #label ]
		ifNone: [ nil ]
]

{ #category : 'accessing' }
CFCompactObjectElement >> titleText [
	^ titleElement text asString
]

{ #category : 'private - accessing' }
CFCompactObjectElement >> titleValueFromObject [
	object ifNil: [ ^ nil ].
	^ (object respondsTo: #label)
		ifTrue: [ object label ]
		ifFalse: [ nil ]
]

{ #category : 'private - updating' }
CFCompactObjectElement >> updateTitleFromValue: aValue [
	titleElement text: (self displayTitleFor: aValue)
]

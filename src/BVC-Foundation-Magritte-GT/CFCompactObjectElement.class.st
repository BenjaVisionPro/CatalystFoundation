Class {
	#name : 'CFCompactObjectElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'object',
		'memento',
		'iconContainer',
		'titleElement',
		'identifierElement',
		'showsIdentifier'
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
	| titleAptitude identifierAptitude |
	super initialize.

	iconContainer := CFIconTile new
		beSmall;
		yourself.
	titleAptitude := BrGlamorousLabelAptitude new
		glamorousRegularFont;
		yourself.
	titleElement := BrLabel new
		hMatchParent;
		vFitContent;
		aptitude: titleAptitude;
		yourself.
	identifierAptitude := BrGlamorousLabelAptitude new
		glamorousRegularFont;
		fontSize: 11;
		yourself.
	identifierElement := BrLabel new
		hMatchParent;
		vFitContent;
		visibility: BlVisibility gone;
		aptitude: identifierAptitude;
		yourself.
	showsIdentifier := false.

	self
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 5 left: 6 bottom: 5 right: 6);
		layout: BlLinearLayout horizontal alignCenterLeft;
		cellSpacing: 8;
		addChild: iconContainer as: #icon;
		addChild: (BrVerticalPane new
			hMatchParent;
			vFitContent;
			cellSpacing: 1;
			addChild: titleElement as: #title;
			addChild: identifierElement as: #identifier;
			yourself) as: #text;
		addAptitude: (BrLazyStyleCommonAptitude new
			@ titleAptitude label;
			default: [ :aStyle |
				aStyle foreground: self theme typography primaryForeground ]);
		addAptitude: (BrLazyStyleCommonAptitude new
			@ identifierAptitude label;
			default: [ :aStyle |
				aStyle foreground: self theme typography tertiaryForeground ]);
		yourself
]


{ #category : 'configuration - icon size' }
CFCompactObjectElement >> beSmall [
	iconContainer beSmall.
	^ self
]

{ #category : 'configuration - icon size' }
CFCompactObjectElement >> beMedium [
	iconContainer beMedium.
	^ self
]

{ #category : 'configuration - icon size' }
CFCompactObjectElement >> beLarge [
	iconContainer beLarge.
	^ self
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
	self
		observeMementoLabel;
		observeMementoIdentifier
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
		refreshTitle;
		refreshIdentifier
]

{ #category : 'private - updating' }
CFCompactObjectElement >> refreshIcon [
	| anIconName anIconElement aDescription |
	object ifNil: [
		iconContainer visibility: BlVisibility gone.
		^ self ].

	aDescription := object iconDescription.
	anIconName := object icon ifNil: [ aDescription default ].
	anIconName ifNil: [
		iconContainer visibility: BlVisibility gone.
		^ self ].

	iconContainer visibility: BlVisibility visible.
	anIconElement := FontAwesomeIcons defaultStyle icon: anIconName.
	iconContainer icon: anIconElement
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

{ #category : 'private - accessing' }
CFCompactObjectElement >> titleDescriptionInMemento [
	memento ifNil: [ ^ nil ].
	^ memento magritteDescription
		detect: [ :each | each handlesSelector: #label ]
		ifNone: [ nil ]
]


{ #category : 'accessing' }
CFCompactObjectElement >> showIdentifier [
	showsIdentifier := true.
	self refreshIdentifier
]

{ #category : 'accessing' }
CFCompactObjectElement >> hideIdentifier [
	showsIdentifier := false.
	identifierElement visibility: BlVisibility gone
]

{ #category : 'accessing' }
CFCompactObjectElement >> identifierElement [
	^ identifierElement
]

{ #category : 'private - accessing' }
CFCompactObjectElement >> identifierDescriptionInMemento [
	memento ifNil: [ ^ nil ].
	^ memento magritteDescription
		detect: [ :each | each handlesSelector: #identifier ]
		ifNone: [ nil ]
]

{ #category : 'private - accessing' }
CFCompactObjectElement >> identifierValueFromObject [
	object ifNil: [ ^ nil ].
	^ object identifier
]

{ #category : 'private - updating' }
CFCompactObjectElement >> observeMementoIdentifier [
	| aDescription |
	memento ifNil: [ ^ self ].
	aDescription := self identifierDescriptionInMemento.
	aDescription ifNil: [ ^ self ].

	self withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theElement :aSink |
				self updateIdentifierFromValue: aSink value currentValue ].
		(memento readObservableValueUsing: aDescription)
			observe: anElementSink ]
]

{ #category : 'private - updating' }
CFCompactObjectElement >> refreshIdentifier [
	| aValue |
	showsIdentifier ifFalse: [
		identifierElement visibility: BlVisibility gone.
		^ self ].
	aValue := memento
		ifNil: [ self identifierValueFromObject ]
		ifNotNil: [ :aMemento |
			self identifierDescriptionInMemento
				ifNil: [ self identifierValueFromObject ]
				ifNotNil: [ :aDescription | aMemento readUsing: aDescription ] ].
	self updateIdentifierFromValue: aValue
]

{ #category : 'private - updating' }
CFCompactObjectElement >> updateIdentifierFromValue: aValue [
	| aString |
	aString := aValue ifNil: [ '' ] ifNotNil: [ aValue asString ].
	identifierElement text: aString.
	identifierElement visibility: (aString isEmpty
		ifTrue: [ BlVisibility gone ]
		ifFalse: [ BlVisibility visible ])
]

{ #category : 'accessing' }
CFCompactObjectElement >> titleElement [
	^ titleElement
]

{ #category : 'accessing' }
CFCompactObjectElement >> titleText [
	^ titleElement text asString
]

{ #category : 'private - accessing' }
CFCompactObjectElement >> titleValueFromObject [
	object ifNil: [ ^ nil ].
	^ object label
]

{ #category : 'private - updating' }
CFCompactObjectElement >> updateTitleFromValue: aValue [
	titleElement text: (self displayTitleFor: aValue)
]

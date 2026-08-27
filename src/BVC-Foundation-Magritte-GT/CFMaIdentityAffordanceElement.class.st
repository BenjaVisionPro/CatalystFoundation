"
I am responsible for presenting and editing an object's icon, label, and identifier as one compact Foundation identity affordance.
"
Class {
	#name : 'CFMaIdentityAffordanceElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'memento',
		'iconContainer',
		'textContainer',
		'labelElement',
		'identifierElement',
		'labelAptitude',
		'identifierAptitude'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'private - binding' }
CFMaIdentityAffordanceElement >> bindEditable: anEditableLabel toSelector: aSelector [
	| aDescription |
	aDescription := self descriptionHandling: aSelector.
	aDescription ifNil: [
		anEditableLabel visibility: BlVisibility gone.
		^ self ].

	anEditableLabel
		visibility: BlVisibility visible;
		when: BrEditorAcceptWish
		do: [ :aWish |
			GtMagritteBuilderUtility
				writeText: aWish text
				using: aDescription
				memento: memento
				element: anEditableLabel ].

	anEditableLabel withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theLabel :aSink |
				| aValue |
				aValue := aSink value currentValue.
				theLabel text: (aValue ifNil: [ '' ] ifNotNil: #asString) ].
		(memento readObservableValueUsing: aDescription)
			observe: anElementSink ]
]

{ #category : 'private - binding' }
CFMaIdentityAffordanceElement >> bindIconTile: anIconTile using: aDescription [
	anIconTile withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :aTile :aSink |
				| aValue anIcon |
				aValue := aSink value currentValue.
				anIcon := aDescription blocStencil
					model: aValue;
					description: aDescription;
					memento: memento;
					asElement.
				aTile icon: anIcon ].

		(memento readObservableValueUsing: aDescription) observe: anElementSink ]
]

{ #category : 'private - building' }
CFMaIdentityAffordanceElement >> buildIconEditor [
	| aDescription anIconTile |
	iconContainer removeChildren.
	aDescription := self descriptionHandling: #icon.
	aDescription ifNil: [ ^ self ].

	anIconTile := CFIconTile new
		beLarge;
		yourself.
	anIconTile constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	self bindIconTile: anIconTile using: aDescription.
	iconContainer addChild: anIconTile.

	aDescription isReadOnly ifFalse: [
		iconContainer addChild: (self newIconFieldFor: aDescription) ]
]

{ #category : 'private - accessing' }
CFMaIdentityAffordanceElement >> descriptionHandling: aSelector [
	memento ifNil: [ ^ nil ].
	^ memento magritteDescription
		detect: [ :each | each handlesSelector: aSelector ]
		ifNone: [ nil ]
]

{ #category : 'accessing' }
CFMaIdentityAffordanceElement >> iconContainer [
	^ iconContainer
]

{ #category : 'accessing' }
CFMaIdentityAffordanceElement >> identifierElement [
	^ identifierElement
]

{ #category : 'initialization' }
CFMaIdentityAffordanceElement >> initialize [
	super initialize.

	iconContainer := BrFrame new
		hExact: 44;
		vExact: 44;
		layout: BlFrameLayout new;
		constraintsDo: [ :c | c linear vertical alignCenter ];
		yourself.

	textContainer := BrFrame new
		hFitContent;
		vFitContent;
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c linear vertical alignTop.
			c margin: (BlInsets top: 2) ];
		yourself.

	labelElement := self
		newEditableTextWithFontSize: self theme typography titleFontSize
		foreground: self theme typography titleForeground
		aptitudeInto: [ :anAptitude | labelAptitude := anAptitude ].
	identifierElement := self
		newEditableTextWithFontSize: self theme typography metadataFontSize
		foreground: self theme typography metadataForeground
		aptitudeInto: [ :anAptitude | identifierAptitude := anAptitude ].

	labelElement constraintsDo: [ :c |
		c frame horizontal alignLeft.
		c frame vertical alignTop ].
	identifierElement constraintsDo: [ :c |
		c frame horizontal alignLeft.
		c frame vertical alignTop.
		c margin: (BlInsets top: 17) ].

	textContainer
		addChild: labelElement as: #label;
		addChild: identifierElement as: #identifier.

	self
		hFitContent;
		vFitContent;
		cellSpacing: 4;
		padding: (BlInsets top: 0 right: 4 bottom: 0 left: 3);
		layout: BlLinearLayout horizontal;
		addChild: iconContainer as: #icon;
		addChild: textContainer as: #text;
		yourself
]

{ #category : 'accessing' }
CFMaIdentityAffordanceElement >> labelElement [
	^ labelElement
]

{ #category : 'accessing' }
CFMaIdentityAffordanceElement >> memento [
	^ memento
]

{ #category : 'accessing' }
CFMaIdentityAffordanceElement >> memento: aMemento [
	memento := aMemento.
	self
		buildIconEditor;
		bindEditable: labelElement toSelector: #label;
		bindEditable: identifierElement toSelector: #identifier;
		updateTextContainerVisibility
]

{ #category : 'private - building' }
CFMaIdentityAffordanceElement >> newEditableTextWithFontSize: aNumber foreground: aColor aptitudeInto: anAptitudeBlock [
	| anAptitude |
	anAptitude := (CFGlamorousEditableLabelAptitude
		background: Color transparent
		focused: Color transparent)
			glamorousRegularFont;
			fontSize: aNumber;
			foreground: aColor;
			defaultForeground: aColor;
			minWidth: 1;
			yourself.
	anAptitudeBlock value: anAptitude.

	^ CFEditableLabel new
		aptitude: anAptitude;
		fitContent;
		yourself
]


{ #category : #'theme - applying' }
CFMaIdentityAffordanceElement >> applyThemeTypography [
	labelAptitude ifNotNil: [
		labelAptitude
			fontSize: self theme typography titleFontSize;
			foreground: self theme typography titleForeground;
			defaultForeground: self theme typography titleForeground ].
	identifierAptitude ifNotNil: [
		identifierAptitude
			fontSize: self theme typography metadataFontSize;
			foreground: self theme typography metadataForeground;
			defaultForeground: self theme typography metadataForeground ]
]

{ #category : #'theme - applying' }
CFMaIdentityAffordanceElement >> onThemeChanged [
	super onThemeChanged.
	self applyThemeTypography
]

{ #category : 'private - building' }
CFMaIdentityAffordanceElement >> newIconFieldFor: aDescription [
	^ FontAwesomeIconFieldElement new
		fieldViewModel: (GtMagritteFieldViewModel new
			memento: memento;
			description: aDescription;
			yourself);
		opacity: 0;
		hMatchParent;
		vMatchParent;
		padding: BlInsets empty;
		yourself
]

{ #category : 'private - updating' }
CFMaIdentityAffordanceElement >> updateTextContainerVisibility [
	((self descriptionHandling: #label) isNil
		and: [ (self descriptionHandling: #identifier) isNil ])
		ifTrue: [ textContainer visibility: BlVisibility gone ]
		ifFalse: [ textContainer visibility: BlVisibility visible ]
]

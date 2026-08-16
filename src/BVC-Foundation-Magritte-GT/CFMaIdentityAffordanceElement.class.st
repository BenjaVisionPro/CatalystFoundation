"I am responsible for presenting and editing an object's icon, label, and identifier as one compact Foundation identity affordance."

Class {
	#name : 'CFMaIdentityAffordanceElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'memento',
		'iconContainer',
		'textContainer',
		'labelElement',
		'identifierElement'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'initialization' }
CFMaIdentityAffordanceElement >> initialize [
	super initialize.

	iconContainer := BrFrame new
		hExact: 36;
		vExact: 36;
		layout: BlFrameLayout new;
		constraintsDo: [ :c | c linear vertical alignCenter ];
		yourself.

	textContainer := BrFrame new
		hFitContent;
		vFitContent;
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c linear vertical alignTop.
			c margin: (BlInsets top: 4) ];
		yourself.

	labelElement := self
		newEditableTextWithFontSize: 14
		foreground: (Color black alpha: 0.92).
	identifierElement := self
		newEditableTextWithFontSize: 10
		foreground: (Color black alpha: 0.55)..

	labelElement constraintsDo: [ :c |
		c frame horizontal alignLeft.
		c frame vertical alignTop ].
	identifierElement constraintsDo: [ :c |
		c frame horizontal alignLeft.
		c frame vertical alignTop.
		c margin: (BlInsets top: 15) ].

	textContainer
		addChild: labelElement as: #label;
		addChild: identifierElement as: #identifier.

	self
		hFitContent;
		vExact: 43;
		cellSpacing: 4;
		padding: (BlInsets top: 0 right: 4 bottom: 0 left: 3);
		layout: BlLinearLayout horizontal;
		addChild: iconContainer as: #icon;
		addChild: textContainer as: #text;
		yourself
]

{ #category : 'private - building' }
CFMaIdentityAffordanceElement >> newEditableTextWithFontSize: aNumber foreground: aColor [
	| anAptitude |
	anAptitude := (BrGlamorousEditableLabelAptitude
		background: Color transparent
		focused: self theme item selectedColor)
			glamorousRegularFont;
			fontSize: aNumber;
			foreground: aColor;
			defaultForeground: aColor;
			minWidth: 1;
			yourself.

	^ CFEditableLabel new
		aptitude: anAptitude;
		fitContent;
		yourself
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

{ #category : 'private - accessing' }
CFMaIdentityAffordanceElement >> descriptionHandling: aSelector [
	memento ifNil: [ ^ nil ].
	^ memento magritteDescription
		detect: [ :each | each handlesSelector: aSelector ]
		ifNone: [ nil ]
]

{ #category : 'private - building' }
CFMaIdentityAffordanceElement >> buildIconEditor [
	| aDescription anEditor |
	iconContainer removeChildren.
	aDescription := self descriptionHandling: #icon.
	aDescription ifNil: [ ^ self ].

	anEditor := GtMagritteBuilderUtility
		newIconWithMemento: memento
		using: aDescription.
	anEditor constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	iconContainer addChild: anEditor
]

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

{ #category : 'accessing' }
CFMaIdentityAffordanceElement >> iconContainer [
	^ iconContainer
]

{ #category : 'accessing' }
CFMaIdentityAffordanceElement >> labelElement [
	^ labelElement
]

{ #category : 'accessing' }
CFMaIdentityAffordanceElement >> identifierElement [
	^ identifierElement
]


{ #category : 'private - updating' }
CFMaIdentityAffordanceElement >> updateTextContainerVisibility [
	((self descriptionHandling: #label) isNil
		and: [ (self descriptionHandling: #identifier) isNil ])
		ifTrue: [ textContainer visibility: BlVisibility gone ]
		ifFalse: [ textContainer visibility: BlVisibility visible ]
]

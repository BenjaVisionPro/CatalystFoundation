"
I present an object through an explicit Magritte reference description.
The reference defines which values participate and their order; I own only
the compact icon-and-text layout.
"
Class {
	#name : 'CFCompactObjectElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'object',
		'memento',
		'reference',
		'iconContainer',
		'textPane',
		'titleElement',
		'identifierElement'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'configuration - icon size' }
CFCompactObjectElement >> beLarge [
	iconContainer beLarge.
	^ self
]

{ #category : 'configuration - icon size' }
CFCompactObjectElement >> beMedium [
	iconContainer beMedium.
	^ self
]

{ #category : 'configuration - icon size' }
CFCompactObjectElement >> beSmall [
	iconContainer beSmall.
	^ self
]

{ #category : 'accessing' }
CFCompactObjectElement >> displayedObject [
	^ object
]

{ #category : 'private - reference' }
CFCompactObjectElement >> hideReferenceIcon [
	iconContainer
		removeChildren;
		visibility: BlVisibility gone
]

{ #category : 'accessing' }
CFCompactObjectElement >> iconContainer [
	^ iconContainer
]

{ #category : 'accessing' }
CFCompactObjectElement >> identifierElement [
	^ identifierElement
]

{ #category : 'initialization' }
CFCompactObjectElement >> initialize [
	super initialize.

	iconContainer := CFIconTile new
		beSmall;
		visibility: BlVisibility gone;
		yourself.
	textPane := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 1;
		yourself.

	self
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 5 left: 6 bottom: 5 right: 6);
		layout: BlLinearLayout horizontal alignCenterLeft;
		cellSpacing: 8;
		addChild: iconContainer as: #icon;
		addChild: textPane as: #text
]

{ #category : 'accessing' }
CFCompactObjectElement >> memento [
	^ memento
]

{ #category : 'accessing' }
CFCompactObjectElement >> memento: aMemento [
	memento := aMemento.
	object := aMemento ifNil: [ nil ] ifNotNil: #model.
	self refreshReference
]

{ #category : 'private - reference' }
CFCompactObjectElement >> newReferenceTextElementAt: anIndex [
	| anAptitude aLabel |
	anAptitude := BrGlamorousLabelAptitude new
		glamorousRegularFont;
		yourself.
	aLabel := BrLabel new
		hMatchParent;
		vFitContent;
		aptitude: anAptitude;
		yourself.

	anIndex = 1
		ifTrue: [
			titleElement := aLabel.
			self addAptitude: (BrLazyStyleCommonAptitude new
				@ anAptitude label;
				default: [ :aStyle |
					aStyle foreground: self theme typography primaryForeground ]) ]
		ifFalse: [
			anAptitude fontSize: 11.
			identifierElement ifNil: [ identifierElement := aLabel ].
			self addAptitude: (BrLazyStyleCommonAptitude new
				@ anAptitude label;
				default: [ :aStyle |
					aStyle foreground: self theme typography tertiaryForeground ]) ].

	textPane addChild: aLabel.
	^ aLabel
]

{ #category : 'accessing' }
CFCompactObjectElement >> object [
	^ object
]

{ #category : 'accessing' }
CFCompactObjectElement >> object: anObject [
	object := anObject.
	memento := nil.
	self refreshReference
]

{ #category : 'private - reference' }
CFCompactObjectElement >> prepareForReference [
	iconContainer
		removeChildren;
		visibility: BlVisibility gone.
	textPane removeChildren.
	titleElement := nil.
	identifierElement := nil
]

{ #category : 'accessing' }
CFCompactObjectElement >> reference [
	^ reference
]

{ #category : 'accessing' }
CFCompactObjectElement >> reference: aReferenceDescription [
	reference := aReferenceDescription.
	self refreshReference
]

{ #category : 'private - reference' }
CFCompactObjectElement >> referenceIcon: anIconElement [
	iconContainer
		visibility: BlVisibility visible;
		icon: anIconElement
]

{ #category : 'private - updating' }
CFCompactObjectElement >> refreshReference [
	reference ifNil: [ ^ self ].
	object ifNil: [
		self prepareForReference.
		^ self ].

	CFMaCompactReferenceElementBuilder new
		object: object;
		memento: memento;
		element: self;
		buildUsing: reference
]

{ #category : 'accessing' }
CFCompactObjectElement >> titleElement [
	^ titleElement
]

{ #category : 'accessing' }
CFCompactObjectElement >> titleText [
	^ titleElement
		ifNil: [ '' ]
		ifNotNil: [ :anElement | anElement text asString ]
]

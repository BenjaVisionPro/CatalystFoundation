"
I present an object through an explicit Magritte reference description.

The reference defines which values participate and their order. I own the compact
presentation convention: the first textual value is primary text and each later
textual value is supporting text. Non-text values such as the icon do not count
as text lines.
"
Class {
	#name : 'CFCompactObjectElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'object',
		'memento',
		'reference',
		'iconContainer',
		'iconEditor',
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
	iconEditor ifNotNil: [
		iconEditor
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical matchParent ] ].
	^ self
]

{ #category : 'configuration - icon size' }
CFCompactObjectElement >> beMedium [
	iconContainer beMedium.
	iconEditor ifNotNil: [
		iconEditor
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical matchParent ] ].
	^ self
]

{ #category : 'configuration - icon size' }
CFCompactObjectElement >> beSmall [
	iconContainer beSmall.
	iconEditor ifNotNil: [
		iconEditor
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical matchParent ] ].
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
CFCompactObjectElement >> addReferenceTextElement: aTextElement [
	aTextElement
		margin: BlInsets empty;
		padding: BlInsets empty;
		hMatchParent;
		vFitContent.

	textPane hasChildren
		ifFalse: [
			titleElement := aTextElement.
			self styleAsPrimaryReferenceText: aTextElement ]
		ifTrue: [
			identifierElement ifNil: [ identifierElement := aTextElement ].
			self styleAsSupportingReferenceText: aTextElement ].

	textPane addChild: aTextElement.
	^ aTextElement
]

{ #category : 'private - reference' }
CFCompactObjectElement >> newReferenceTextElement [
	| aLabel |
	aLabel := BrLabel new
		hMatchParent;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new glamorousRegularFont);
		yourself.
	^ self addReferenceTextElement: aLabel
]

{ #category : 'private - appearance' }
CFCompactObjectElement >> styleAsPrimaryReferenceText: aTextElement [
	(aTextElement isKindOf: CFMaCompactIdentityEditorElement)
		ifTrue: [ aTextElement bePrimaryText ]
		ifFalse: [
			self addAptitude: (BrLazyStyleCommonAptitude new
				@ aTextElement aptitude label;
				default: [ :aStyle |
					aStyle foreground: self theme typography primaryForeground ]) ]
]

{ #category : 'private - appearance' }
CFCompactObjectElement >> styleAsSupportingReferenceText: aTextElement [
	(aTextElement isKindOf: CFMaCompactIdentityEditorElement)
		ifTrue: [ aTextElement beSupportingText ]
		ifFalse: [
			aTextElement aptitude fontSize: self theme typography supportingFontSize.
			self addAptitude: (BrLazyStyleCommonAptitude new
				@ aTextElement aptitude label;
				default: [ :aStyle |
					aStyle foreground: self theme typography tertiaryForeground ]) ]
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
	iconEditor := nil.
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
CFCompactObjectElement >> referenceIconEditor: anEditorElement [
	iconEditor := anEditorElement.
	iconContainer
		removeChildren;
		visibility: BlVisibility visible.
	anEditorElement
		margin: BlInsets empty;
		padding: BlInsets empty;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent.
			c frame horizontal alignCenter.
			c frame vertical alignCenter ].
	iconContainer addChild: anEditorElement.
	^ anEditorElement
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

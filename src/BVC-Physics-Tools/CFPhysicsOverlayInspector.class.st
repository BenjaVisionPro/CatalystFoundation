"I define the compact presentation shared by Physics overlay inspectors. Concrete inspectors describe their groups and refresh their values; I own the fixed title, scrolling data area, two-column layout, typography, help icons, tooltips and diagnostic formatting."
Class {
	#name : 'CFPhysicsOverlayInspector',
	#superclass : 'Object',
	#instVars : [ 'element', 'titleElement', 'scrollPane', 'dataElement', 'valueElements' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsOverlayInspector class >> newContent [
	^ self new
		initializeContent;
		yourself
]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> element [ ^ element ]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> titleElement [ ^ titleElement ]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> scrollPane [ ^ scrollPane ]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> dataElement [ ^ dataElement ]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> valueElementAt: aKey [ ^ valueElements at: aKey ]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> valueElements [ ^ valueElements ]

{ #category : 'initialization' }
CFPhysicsOverlayInspector >> initializeContent [
	valueElements := Dictionary new.
	titleElement := self newTitleElement.
	dataElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 3;
		yourself.
	scrollPane := BrScrollPane new
		hMatchParent;
		vFitContent;
		content: dataElement;
		yourself.
	element := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 3;
		addChild: titleElement;
		addChild: scrollPane;
		yourself.
	self configureInspector
]

{ #category : 'initialization' }
CFPhysicsOverlayInspector >> configureInspector [ self subclassResponsibility ]

{ #category : 'building' }
CFPhysicsOverlayInspector >> addTitle: aString [
	titleElement text: aString.
	^ self
]

{ #category : 'building' }
CFPhysicsOverlayInspector >> addGroup: aName fields: associations [
	dataElement addChild: (self newGroup: aName fields: associations).
	^ self
]

{ #category : 'sizing' }
CFPhysicsOverlayInspector >> fitWithinHeight: aHeight [
	| titleHeight bodyHeight |
	titleHeight := titleElement extent y.
	bodyHeight := (aHeight - titleHeight - 3) max: 0.
	element vExact: aHeight.
	scrollPane vExact: bodyHeight.
	^ self
]

{ #category : 'sizing' }
CFPhysicsOverlayInspector >> useNaturalHeight [
	element vFitContent.
	scrollPane vFitContent.
	^ self
]

{ #category : 'sizing' }
CFPhysicsOverlayInspector >> naturalHeight [
	^ titleElement extent y + 3 + dataElement extent y
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newTitleElement [
	^ BrLabel new
		hMatchParent;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.65);
			fontSize: 9);
		text: '';
		yourself
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newGroup: aName fields: associations [
	| group rows index row |
	group := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 1;
		yourself.
	group addChild: (BrLabel new
		hMatchParent;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.38);
			fontSize: 8);
		text: aName asUppercase;
		yourself).
	rows := associations asArray.
	index := 1.
	[ index <= rows size ] whileTrue: [
		row := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			cellSpacing: 4;
			addChild: (self newFieldFor: (rows at: index) key description: (rows at: index) value);
			yourself.
		index + 1 <= rows size
			ifTrue: [ row addChild: (self newFieldFor: (rows at: index + 1) key description: (rows at: index + 1) value) ]
			ifFalse: [ row addChild: self newEmptyField ].
		group addChild: row.
		index := index + 2 ].
	^ group
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newFieldFor: aKey description: aString [
	| valueElement valueContainer |
	valueElement := self newValueElement.
	valueElements at: aKey put: valueElement.
	valueContainer := BlElement new
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		addChild: valueElement;
		yourself.
	valueElement constraintsDo: [ :c |
		c frame horizontal alignRight.
		c frame vertical alignCenter ].
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 2;
		addChild: (self newHelpIconFor: aString);
		addChild: valueContainer;
		yourself
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newEmptyField [
	^ BlElement new
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		yourself
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newHelpIconFor: aString [
	^ (FontAwesomeIcons defaultStyle icon: #questionCircle)
		size: 10 @ 10;
		addAptitude: (BrGlamorousWithExplicitTooltipAptitude text: aString);
		yourself
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newValueElement [
	^ BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: Color black;
			fontSize: 9;
			fontName: 'Source Code Pro');
		text: '';
		yourself
]

{ #category : 'updating' }
CFPhysicsOverlayInspector >> text: aString at: aKey [
	(self valueElementAt: aKey) text: aString.
	^ self
]

{ #category : 'updating' }
CFPhysicsOverlayInspector >> diagnosticNumber: aNumber at: aKey [
	^ self text: (self formatDiagnosticNumber: aNumber) at: aKey
]

{ #category : 'updating' }
CFPhysicsOverlayInspector >> diagnosticPoint: aPoint at: aKey [
	^ self text: (self formatPoint: aPoint) at: aKey
]

{ #category : 'clearing' }
CFPhysicsOverlayInspector >> clearValues [
	valueElements valuesDo: [ :each | each text: '' ].
	^ self
]

{ #category : 'private - formatting' }
CFPhysicsOverlayInspector >> formatDiagnosticNumber: aNumber [
	^ aNumber asFloat printShowingDecimalPlaces: 3
]

{ #category : 'private - formatting' }
CFPhysicsOverlayInspector >> formatPoint: aPoint [
	^ (self formatDiagnosticNumber: aPoint x), ',',
		(self formatDiagnosticNumber: aPoint y)
]

{ #category : 'private - formatting' }
CFPhysicsOverlayInspector >> labelForBody: aBody [
	aBody ifNil: [ ^ 'World anchor' ].
	^ aBody element gtDisplayString
]

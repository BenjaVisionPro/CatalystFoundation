"I provide the compact presentation shared by Physics overlay inspectors. Concrete inspectors describe groups and refresh values; I own the fixed title, bounded scrolling body, two-column geometry, typography, help icons, tooltips and diagnostic formatting. My preferred height is structural and does not depend on a scroll viewport having already been laid out."
Class {
	#name : 'CFPhysicsOverlayInspector',
	#superclass : 'Object',
	#instVars : [ 'element', 'titleElement', 'scrollPane', 'dataElement', 'valueElements', 'preferredDataHeight', 'groupCount' ],
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
	preferredDataHeight := 0.
	groupCount := 0.
	titleElement := self newTitleElement.
	dataElement := BrVerticalPane new
		hMatchParent;
		vExact: 0;
		cellSpacing: self groupSpacing;
		yourself.
	scrollPane := BrScrollPane new
		aptitude: BrScrollPaneAptitude + BrGlamorousWithVerticalScrollbarAptitude;
		hMatchParent;
		vExact: 0;
		content: dataElement;
		yourself.
	element := BrVerticalPane new
		hMatchParent;
		vExact: self titleHeight;
		cellSpacing: self titleBodySpacing;
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
	| fields groupHeight |
	fields := associations asArray.
	groupHeight := self groupHeightForFieldCount: fields size.
	groupCount > 0 ifTrue: [ preferredDataHeight := preferredDataHeight + self groupSpacing ].
	preferredDataHeight := preferredDataHeight + groupHeight.
	dataElement
		vExact: preferredDataHeight;
		addChild: (self newGroup: aName fields: fields height: groupHeight).
	^ self
]

{ #category : 'sizing' }
CFPhysicsOverlayInspector >> fitWithinHeight: aHeight [
	| bodyHeight |
	bodyHeight := (aHeight - self titleHeight - self titleBodySpacing) max: 0.
	element vExact: aHeight.
	scrollPane vExact: bodyHeight.
	^ self
]

{ #category : 'sizing' }
CFPhysicsOverlayInspector >> preferredHeight [
	^ self titleHeight + self titleBodySpacing + preferredDataHeight
]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> titleHeight [ ^ 13 ]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> titleBodySpacing [ ^ 3 ]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> groupTitleHeight [ ^ 11 ]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> fieldRowHeight [ ^ 13 ]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> groupTitleRowSpacing [ ^ 1 ]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> groupSpacing [ ^ 3 ]

{ #category : 'sizing' }
CFPhysicsOverlayInspector >> groupHeightForFieldCount: aCount [
	| rowCount |
	rowCount := (aCount + 1) // 2.
	^ self groupTitleHeight + self groupTitleRowSpacing + (rowCount * self fieldRowHeight)
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newTitleElement [
	^ BrLabel new
		hMatchParent;
		vExact: self titleHeight;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.65);
			fontSize: 9);
		text: '';
		yourself
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newGroup: aName fields: fields height: groupHeight [
	| group index row |
	group := BrVerticalPane new
		hMatchParent;
		vExact: groupHeight;
		cellSpacing: self groupTitleRowSpacing;
		yourself.
	group addChild: (BrLabel new
		hMatchParent;
		vExact: self groupTitleHeight;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.38);
			fontSize: 8);
		text: aName asUppercase;
		yourself).
	index := 1.
	[ index <= fields size ] whileTrue: [
		row := BrHorizontalPane new
			hMatchParent;
			vExact: self fieldRowHeight;
			cellSpacing: 4;
			addChild: (self newFieldFor: (fields at: index) key description: (fields at: index) value);
			yourself.
		index + 1 <= fields size
			ifTrue: [ row addChild: (self newFieldFor: (fields at: index + 1) key description: (fields at: index + 1) value) ]
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
			c vertical matchParent ];
		addChild: valueElement;
		yourself.
	valueElement constraintsDo: [ :c |
		c frame horizontal alignRight.
		c frame vertical alignCenter ].
	^ BrHorizontalPane new
		hMatchParent;
		vExact: self fieldRowHeight;
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
			c vertical exact: self fieldRowHeight ];
		yourself
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newHelpIconFor: aString [
	^ (FontAwesomeIcons defaultStyle icon: #questionCircle)
		size: 10 @ 10;
		margin: (BlInsets top: 1);
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

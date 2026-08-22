"
I provide the compact presentation shared by Physics overlay inspectors. Concrete inspectors describe groups and refresh values; I own the fixed title, bounded scrolling body, two-column geometry, typography, help icons, tooltips and diagnostic formatting. My preferred height is structural and does not depend on a scroll viewport having already been laid out.
"
Class {
	#name : 'CFPhysicsOverlayInspector',
	#superclass : 'Object',
	#instVars : [
		'element',
		'titleElement',
		'scrollPane',
		'dataElement',
		'valueElements',
		'preferredDataHeight',
		'groupCount'
	],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsOverlayInspector class >> newContent [
	^ self new
		initializeContent;
		yourself
]

{ #category : 'building' }
CFPhysicsOverlayInspector >> addGroup: aName fields: associations [
	^ self addGroup: aName fields: associations columns: 2
]

{ #category : 'building' }
CFPhysicsOverlayInspector >> addGroup: aName fields: associations columns: aColumnCount [
	| fields groupHeight |
	fields := associations asArray.
	groupHeight := self groupHeightForFieldCount: fields size columns: aColumnCount.
	preferredDataHeight := preferredDataHeight + groupHeight + self groupSpacing.
	dataElement addChild: (self
		newGroup: aName
		fields: fields
		columns: aColumnCount
		height: groupHeight).
	groupCount := groupCount + 1.
	^ self
]

{ #category : 'building' }
CFPhysicsOverlayInspector >> addTitle: aString [
	titleElement text: aString.
	^ self
]

{ #category : 'clearing' }
CFPhysicsOverlayInspector >> clearValues [
	valueElements valuesDo: [ :each | each text: '' ].
	^ self
]

{ #category : 'initialization' }
CFPhysicsOverlayInspector >> configureInspector [ self subclassResponsibility
]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> dataElement [ ^ dataElement
]

{ #category : 'updating' }
CFPhysicsOverlayInspector >> diagnosticNumber: aNumber at: aKey [
	^ self text: (self formatDiagnosticNumber: aNumber) at: aKey
]

{ #category : 'updating' }
CFPhysicsOverlayInspector >> diagnosticPoint: aPoint at: aKey [
	^ self text: (self formatPoint: aPoint) at: aKey
]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> element [ ^ element
]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> fieldRowHeight [ ^ 13
]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> fieldSpacing [ ^ 4
]

{ #category : 'sizing' }
CFPhysicsOverlayInspector >> fieldWidthForColumns: aColumnCount [
	^ (self panelWidth - self panelHorizontalPadding
		- ((aColumnCount + 1) * self fieldSpacing)) / aColumnCount
]

{ #category : 'sizing' }
CFPhysicsOverlayInspector >> fitWithinHeight: aHeight [
	| bodyHeight |
	bodyHeight := (aHeight - self titleHeight - self titleBodySpacingHeight) max: 0.
	element vExact: aHeight.
	scrollPane vExact: bodyHeight.
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

{ #category : 'sizing' }
CFPhysicsOverlayInspector >> groupHeightForFieldCount: aCount columns: aColumnCount [
	| rowCount |
	rowCount := (aCount + aColumnCount - 1) // aColumnCount.
	"BlLinearLayout applies spacing before the title, between every child, and
	after the last row. With one title and rowCount rows that is rowCount + 2 gaps."
	^ self groupTitleHeight
		+ (rowCount * self fieldRowHeight)
		+ ((rowCount + 2) * self groupTitleRowSpacing)
]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> groupSpacing [ ^ 3
]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> groupTitleHeight [ ^ 11
]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> groupTitleRowSpacing [ ^ 1
]

{ #category : 'initialization' }
CFPhysicsOverlayInspector >> initializeContent [
	valueElements := Dictionary new.
	preferredDataHeight := self groupSpacing.
	groupCount := 0.
	titleElement := self newTitleElement.
	dataElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: self groupSpacing;
		yourself.
	scrollPane := BrScrollPane new
		allowMeAndChildrenMouseEvents;
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

{ #category : 'private - formatting' }
CFPhysicsOverlayInspector >> labelForBody: aBody [
	aBody ifNil: [ ^ 'World anchor' ].
	^ aBody element gtDisplayString
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newEmptyFieldWidth: aWidth [
	^ BlElement new
		clipChildren: true;
		constraintsDo: [ :c |
			c horizontal exact: aWidth.
			c vertical exact: self fieldRowHeight ];
		yourself
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newFieldFor: aKey description: aString width: aWidth [
	| valueElement valueContainer valueWidth field |
	valueElement := self newValueElement.
	valueElements at: aKey put: valueElement.
	"The field has two children. BlLinearLayout contributes three spacing gaps:
	before the icon, between icon and value, and after the value."
	valueWidth := (aWidth - 10 - (3 * 2)) max: 0.
	valueContainer := BlElement new
		layout: BlFrameLayout new;
		clipChildren: true;
		constraintsDo: [ :c |
			c horizontal exact: valueWidth.
			c vertical matchParent ];
		addChild: valueElement;
		yourself.
	valueElement constraintsDo: [ :c |
		c frame horizontal alignLeft.
		c frame vertical alignCenter ].
	field := BrHorizontalPane new
		hExact: aWidth;
		vExact: self fieldRowHeight;
		cellSpacing: 2;
		clipChildren: true;
		addChild: (self newHelpIconFor: aString);
		addChild: valueContainer;
		yourself.
	^ field
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newGroup: aName fields: fields columns: aColumnCount height: groupHeight [
	| group index rowFields |
	group := BrVerticalPane new
		hMatchParent;
		vExact: groupHeight;
		cellSpacing: self groupTitleRowSpacing;
		clipChildren: true;
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
		rowFields := fields copyFrom: index to: (index + aColumnCount - 1 min: fields size).
		group addChild: (self newTableRowFor: rowFields columns: aColumnCount).
		index := index + aColumnCount ].
	^ group
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newHelpIconFor: aString [
	^ (FontAwesomeIcons defaultStyle circleQuestion)
		size: 10 @ 10;
		margin: (BlInsets top: 1);
		addAptitude: (BrGlamorousWithExplicitTooltipAptitude text: aString);
		yourself
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newTableRowFor: fields columns: aColumnCount [
	| row fieldWidth columnIndex |
	fieldWidth := self fieldWidthForColumns: aColumnCount.
	row := BrHorizontalPane new
		hMatchParent;
		vExact: self fieldRowHeight;
		cellSpacing: self fieldSpacing;
		clipChildren: true;
		yourself.
	columnIndex := 1.
	[ columnIndex <= aColumnCount ] whileTrue: [
		columnIndex <= fields size
			ifTrue: [
				row addChild: (self
					newFieldFor: (fields at: columnIndex) key
					description: (fields at: columnIndex) value
					width: fieldWidth) ]
			ifFalse: [ row addChild: (self newEmptyFieldWidth: fieldWidth) ].
		columnIndex := columnIndex + 1 ].
	^ row
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

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> panelHorizontalPadding [ ^ 12
]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> panelWidth [ ^ 230
]

{ #category : 'sizing' }
CFPhysicsOverlayInspector >> preferredHeight [
	^ self titleHeight + self titleBodySpacingHeight + preferredDataHeight
]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> scrollPane [ ^ scrollPane
]

{ #category : 'updating' }
CFPhysicsOverlayInspector >> text: aString at: aKey [
	(self valueElementAt: aKey) text: aString.
	^ self
]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> titleBodySpacing [ ^ 3
]

{ #category : 'sizing' }
CFPhysicsOverlayInspector >> titleBodySpacingHeight [
	"BlLinearLayout applies cell spacing before the first child, between children,
	and after the last child. The title/body pane has two children."
	^ 3 * self titleBodySpacing
]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> titleElement [ ^ titleElement
]

{ #category : 'sizing constants' }
CFPhysicsOverlayInspector >> titleHeight [ ^ 13
]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> valueElementAt: aKey [ ^ valueElements at: aKey
]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> valueElements [ ^ valueElements
]

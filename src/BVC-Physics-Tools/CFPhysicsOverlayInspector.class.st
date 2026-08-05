"I define the compact presentation shared by Physics overlay inspectors. Concrete inspectors describe their groups and refresh their values; I own layout, typography, help icons, tooltips and diagnostic formatting."
Class {
	#name : 'CFPhysicsOverlayInspector',
	#superclass : 'Object',
	#instVars : [ 'element', 'valueElements' ],
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
CFPhysicsOverlayInspector >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> valueElementAt: aKey [
	^ valueElements at: aKey
]

{ #category : 'accessing' }
CFPhysicsOverlayInspector >> valueElements [
	^ valueElements
]

{ #category : 'initialization' }
CFPhysicsOverlayInspector >> initializeContent [
	valueElements := Dictionary new.
	element := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 3;
		yourself.
	self configureInspector
]

{ #category : 'initialization' }
CFPhysicsOverlayInspector >> configureInspector [
	self subclassResponsibility
]

{ #category : 'building' }
CFPhysicsOverlayInspector >> addTitle: aString [
	element addChild: (self newTitle: aString).
	^ self
]

{ #category : 'building' }
CFPhysicsOverlayInspector >> addGroup: aName fields: associations [
	element addChild: (self newGroup: aName fields: associations).
	^ self
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newTitle: aString [
	^ BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.65);
			fontSize: 9);
		text: aString;
		yourself
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newGroup: aName fields: associations [
	| group |
	group := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 2;
		yourself.
	group addChild: (BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.38);
			fontSize: 9);
		text: aName asUppercase;
		yourself).
	associations do: [ :each |
		group addChild: (self newRowFor: each key description: each value) ].
	^ group
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newRowFor: aKey description: aString [
	| valueElement |
	valueElement := self newValueElement.
	valueElements at: aKey put: valueElement.
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 4;
		addChild: (self newHelpIconFor: aString);
		addChild: valueElement;
		yourself
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newHelpIconFor: aString [
	^ (FontAwesomeIcons defaultStyle icon: #questionCircle)
		size: 12 @ 12;
		addAptitude: (BrGlamorousWithExplicitTooltipAptitude text: aString);
		yourself
]

{ #category : 'private - building' }
CFPhysicsOverlayInspector >> newValueElement [
	^ BrLabel new
		hMatchParent;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: Color black;
			fontSize: 10;
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
	^ (self formatDiagnosticNumber: aPoint x), ' @ ',
		(self formatDiagnosticNumber: aPoint y)
]

{ #category : 'private - formatting' }
CFPhysicsOverlayInspector >> labelForBody: aBody [
	aBody ifNil: [ ^ 'World anchor' ].
	^ aBody element gtDisplayString
]

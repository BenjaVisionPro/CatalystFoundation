Class {
	#name : 'CFMaFormElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'headerElement',
		'contentElement',
		'bodyElement',
		'footerElement'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'accessing' }
CFMaFormElement >> bodyElement [
	^ bodyElement
]

{ #category : 'accessing' }
CFMaFormElement >> contentElement [
	^ contentElement
]

{ #category : 'accessing' }
CFMaFormElement >> footerElement [
	^ footerElement
]

{ #category : 'accessing' }
CFMaFormElement >> headerElement [
	^ headerElement
]


{ #category : 'accessing' }
CFMaFormElement >> selected: aBoolean [
	self border: (BlBorder
		paint: (aBoolean
			ifTrue: [ BrGlamorousColors focusedEditorBorderColor ]
			ifFalse: [ Color black alpha: 0.13 ])
		width: (aBoolean ifTrue: [ 2 ] ifFalse: [ 1 ]))
]

{ #category : 'initialization' }
CFMaFormElement >> initialize [
	super initialize.
	self
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		background: (Color black alpha: 0.025);
		border: (BlBorder paint: (Color black alpha: 0.13) width: 1);
		margin: (BlInsets all: 4);
		cellSpacing: 0;
		hMatchParent;
		vFitContent
]

{ #category : 'building' }
CFMaFormElement >> header: aHeaderElement body: aBodyElement footer: aFooterElement [
	headerElement := aHeaderElement.
	bodyElement := aBodyElement.
	footerElement := aFooterElement.

	contentElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 0;
		addChild: bodyElement as: #body;
		addChild: footerElement as: #footer;
		yourself.

	headerElement contentElement: contentElement.
	self
		addChild: headerElement as: #header;
		addChild: contentElement as: #content
]

{ #category : 'accessing' }
CFMaFormElement >> expanded [
	^ headerElement expanded
]

{ #category : 'accessing' }
CFMaFormElement >> expanded: aBoolean [
	headerElement expanded: aBoolean
]

{ #category : 'accessing' }
CFMaFormElement >> beCollapsed [
	self expanded: false
]

{ #category : 'accessing' }
CFMaFormElement >> beExpanded [
	self expanded: true
]

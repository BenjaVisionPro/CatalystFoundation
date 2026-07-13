Class {
	#name : 'CFMaFormElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'headerElement',
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
CFMaFormElement >> footerElement [
	^ footerElement
]

{ #category : 'accessing' }
CFMaFormElement >> headerElement [
	^ headerElement
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
	headerElement bodyElement: bodyElement.
	self
		addChild: headerElement as: #header;
		addChild: bodyElement as: #body;
		addChild: footerElement as: #footer
]

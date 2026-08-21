Class {
	#name : 'CFMaDetailPopupFieldElement',
	#superclass : 'BrFrame',
	#instVars : [
		'popup'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPopupFieldElement >> initialize [
	super initialize.
	self
		hMatchParent;
		vFitContent;
		padding: (BlInsets right: CFMaDetailScalarFieldMetrics trailingControlInset);
		margin: BlInsets empty;
		background: Color transparent;
		border: BlBorder empty
]

{ #category : 'accessing' }
CFMaDetailPopupFieldElement >> popup [
	^ popup
]

{ #category : 'accessing' }
CFMaDetailPopupFieldElement >> popup: aPopup [
	popup ifNotNil: [ self removeChild: popup ].
	popup := aPopup.
	popup constraintsDo: [ :c |
		c frame horizontal alignRight.
		c frame vertical alignCenter ].
	self addChild: popup
]

{ #category : 'layout' }
CFMaDetailPopupFieldElement >> supportsBaseline [
	^ popup notNil and: [ popup supportsBaseline ]
]

{ #category : 'layout' }
CFMaDetailPopupFieldElement >> baselineOffset [
	^ popup baselineOffset
]

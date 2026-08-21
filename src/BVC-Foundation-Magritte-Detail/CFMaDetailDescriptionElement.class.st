Class {
	#name : 'CFMaDetailDescriptionElement',
	#superclass : 'BlElement',
	#instVars : [
		'primaryElement',
		'supportingElement'
	],
	#category : 'BVC-Foundation-Magritte-Detail-Elements',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Elements'
}

{ #category : 'initialization' }
CFMaDetailDescriptionElement >> initialize [
	super initialize.
	self
		layout: (BlLinearLayout vertical cellSpacing: 1);
		background: Color transparent;
		border: BlBorder empty;
		padding: BlInsets empty;
		constraintsDo: [ :c |
			c horizontal fitContentLimited.
			c vertical fitContent ]
]

{ #category : 'initialization' }
CFMaDetailDescriptionElement >> primary: aPrimaryElement supporting: aSupportingElement [
	self removeChildren.
	primaryElement := aPrimaryElement.
	supportingElement := aSupportingElement.

	primaryElement ifNotNil: [
		primaryElement margin: BlInsets empty.
		self addChild: primaryElement ].
	supportingElement ifNotNil: [
		supportingElement margin: BlInsets empty.
		self addChild: supportingElement ].
	^ self
]

{ #category : 'accessing' }
CFMaDetailDescriptionElement >> primaryElement [
	^ primaryElement
]

{ #category : 'accessing' }
CFMaDetailDescriptionElement >> supportingElement [
	^ supportingElement
]

{ #category : 'layout' }
CFMaDetailDescriptionElement >> supportsBaseline [
	^ primaryElement notNil and: [ primaryElement supportsBaseline ]
]

{ #category : 'layout' }
CFMaDetailDescriptionElement >> baselineOffset [
	self supportsBaseline ifFalse: [ ^ super baselineOffset ].
	^ primaryElement baselineOffset
]

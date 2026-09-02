"I am the visible Atelier host when orchestration UI is configured around a normal Foundation Magritte form.

The form remains the element produced by CFMaViewModel. I only arrange Atelier-owned UI beside it; I do not render Magritte descriptions myself."
Class {
	#name : 'CFAtelierElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'paletteElement',
		'formElement',
		'removeDropTarget'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'initialization' }
CFAtelierElement >> initialize [
	super initialize.
	self
		hMatchParent;
		vFitContent;
		cellSpacing: 12
]

{ #category : 'accessing' }
CFAtelierElement >> formElement [
	^ formElement
]

{ #category : 'accessing' }
CFAtelierElement >> formElement: anElement [
	formElement ifNotNil: [ self removeChild: formElement ].
	formElement := anElement.
	formElement
		hMatchParent;
		vFitContent.
	self addChild: formElement
]

{ #category : 'editing - motion' }
CFAtelierElement >> replaceFormElementWithMotion: anElement [
	| previousForm participants transaction |
	previousForm := formElement.
	(previousForm isNil or: [ self isAttachedToSceneGraph not ])
		ifTrue: [ ^ self formElement: anElement ].
	participants := paletteElement
		ifNil: [ #() ]
		ifNotNil: [ { paletteElement } ].
	participants isEmpty ifTrue: [ ^ self formElement: anElement ].
	anElement
		hMatchParent;
		vFitContent.
	transaction := CFMotionLayoutTransaction on: self.
	transaction
		affecting: participants;
		mutate: [
			self removeChild: previousForm.
			formElement := anElement.
			self addChild: formElement ];
		fadeIn: anElement;
		play.
	^ anElement
]

{ #category : 'accessing' }
CFAtelierElement >> paletteElement [
	^ paletteElement
]

{ #category : 'accessing' }
CFAtelierElement >> palette: anAtelierPalette [
	paletteElement ifNotNil: [ self removeChild: paletteElement ].
	paletteElement := CFAtelierPaletteElement new
		palette: anAtelierPalette;
		yourself.
	self addChild: paletteElement at: 1.
	removeDropTarget ifNil: [
		removeDropTarget := CFAtelierRemoveDropTarget new.
		self addChild: removeDropTarget at: 2 ]
]

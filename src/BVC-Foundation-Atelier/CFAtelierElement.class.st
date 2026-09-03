"I am the visible Atelier host when orchestration UI is configured around a normal Foundation Magritte form.

The Foundation-selected form remains the primary surface and fills me. Atelier-owned transient tools such as the palette float over that surface instead of consuming layout space. I do not render Magritte descriptions myself."
Class {
	#name : 'CFAtelierElement',
	#superclass : 'BrFrame',
	#instVars : [
		'paletteElement',
		'formElement',
		'removeDropTarget',
		'removeOperationBlock'
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
		vMatchParent;
		clipChildren: true
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
		vMatchParent.
	self addChild: formElement at: 1
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
		vMatchParent.
	transaction := CFMotionLayoutTransaction on: self.
	transaction
		affecting: participants;
		mutate: [
			self removeChild: previousForm.
			formElement := anElement.
			self addChild: formElement at: 1 ];
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
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: 16 @ 16;
		yourself.
	self addChild: paletteElement
]

{ #category : 'configuration' }
CFAtelierElement >> removeOperationFor: aBlock [
	"Removal remains an Atelier semantic operation, but it is no longer represented as permanent workspace geometry. Clients can expose removal through selection/keyboard or another transient affordance."
	removeOperationBlock := aBlock.
	removeDropTarget ifNotNil: [ removeDropTarget operationFor: aBlock ]
]

"I am the public Atelier entry point when there is no root object yet.

I show Atelier-owned supply UI and an empty root target. When a palette candidate becomes the root, I replace only the empty root area with that object's ordinary CFAtelierViewModel form. Foundation Magritte still owns the form and presentation."
Class {
	#name : 'CFAtelierEmptyViewModel',
	#superclass : 'Object',
	#instVars : [
		'palette',
		'element',
		'rootObject',
		'configuration',
		'rootViewModel'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'instance creation' }
CFAtelierEmptyViewModel class >> palette: anAtelierPalette [
	^ self new palette: anAtelierPalette; yourself
]


{ #category : 'instance creation' }
CFAtelierEmptyViewModel class >> configuration: anAtelierConfiguration [
	^ self new configuration: anAtelierConfiguration; yourself
]

{ #category : 'api - converting' }
CFAtelierEmptyViewModel >> asElement [
	| anEmptyRoot |
	element ifNotNil: [ ^ element ].
	anEmptyRoot := CFAtelierEmptyRootElement new.
	element := CFAtelierElement new
		palette: palette;
		formElement: anEmptyRoot;
		yourself.
	CFAtelierRootDropTarget
		installOn: anEmptyRoot
		adopt: [ :anObject | self adoptRootObject: anObject ].
	^ element
]

{ #category : 'editing' }
CFAtelierEmptyViewModel >> adoptRootObject: anObject [
	anObject hasMagritteDescription ifFalse: [ ^ false ].
	rootObject := anObject.
	rootViewModel := CFAtelierViewModel forObject: anObject.
	configuration ifNotNil: [ configuration applyEditingTo: rootViewModel ].
	element ifNotNil: [ element replaceFormElementWithMotion: rootViewModel asElement ].
	^ true
]

{ #category : 'accessing' }
CFAtelierEmptyViewModel >> palette [ ^ palette ]

{ #category : 'accessing' }
CFAtelierEmptyViewModel >> palette: anAtelierPalette [ palette := anAtelierPalette ]

{ #category : 'accessing' }
CFAtelierEmptyViewModel >> rootObject [ ^ rootObject ]


{ #category : 'configuration' }
CFAtelierEmptyViewModel >> configuration: anAtelierConfiguration [
	configuration := anAtelierConfiguration.
	palette := anAtelierConfiguration palette
]

{ #category : 'accessing' }
CFAtelierEmptyViewModel >> rootViewModel [
	^ rootViewModel
]

"
I present icon content inside Foundation's icon chrome. I am a normal Bloc frame: my extent is set with standard Bloc sizing, and supplied scalable icons preserve their proportions within the available icon area.
"
Class {
	#name : 'CFIconTile',
	#superclass : 'BrFrame',
	#instVars : [
		'iconElement',
		'backgroundColor',
		'tileSize',
		'lightBorderAptitude'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'private - appearance' }
CFIconTile >> appearanceBaseColorFor: aColor [
	| strength |
	strength := tileSize > self mediumSize
		ifTrue: [ 0.10 ]
		ifFalse: [ 0.0 ].
	strength = 0.0 ifTrue: [ ^ aColor ].
	^ Color
		r: aColor red + ((1.0 - aColor red) * strength)
		g: aColor green + ((1.0 - aColor green) * strength)
		b: aColor blue + ((1.0 - aColor blue) * strength)
		alpha: aColor alpha
]

{ #category : 'accessing' }
CFIconTile >> backgroundColor: aColor [
	backgroundColor := aColor.
	self updateTileBackground.
	^ self
]

{ #category : 'sizing' }
CFIconTile >> beLarge [
	^ self size: self largeSize asPoint
]

{ #category : 'sizing' }
CFIconTile >> beMedium [
	^ self size: self mediumSize asPoint
]

{ #category : 'sizing' }
CFIconTile >> beSmall [
	^ self size: self smallSize asPoint
]

{ #category : 'private - sizing' }
CFIconTile >> borderWidth [
	^ tileSize * (1.5 / 28.0)
]

{ #category : 'private - sizing' }
CFIconTile >> cornerRadius [
	^ tileSize * (7.0 / 28.0)
]

{ #category : 'private - appearance' }
CFIconTile >> defaultBackgroundColor [
	^ Color r: 140 g: 140 b: 140 range: 255
]

{ #category : 'accessing' }
CFIconTile >> icon: anIconElement [
	iconElement ifNotNil: [ self removeChild: iconElement ].
	iconElement := anIconElement
		color: Color white;
		size: self iconExtent;
		yourself.
	iconElement constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	self addChild: iconElement.
	^ self
]

{ #category : 'private - sizing' }
CFIconTile >> iconExtent [
	| anIconSize |
	anIconSize := tileSize * (20.0 / 28.0).
	^ anIconSize @ anIconSize
]

{ #category : 'initialization' }
CFIconTile >> initialize [
	super initialize.
	backgroundColor := nil.
	lightBorderAptitude := CFLightBorderAptitude new
		beFlat;
		intensity: 0.5;
		raiseBorderInside;
		yourself.
	self
		border: BlBorder empty;
		clipChildren: true;
		addAptitude: lightBorderAptitude;
		beMedium
]

{ #category : 'private - sizing' }
CFIconTile >> largeSize [
	^ 44
]

{ #category : 'private - sizing' }
CFIconTile >> mediumSize [
	^ 28
]

{ #category : 'sizing' }
CFIconTile >> size: anExtent [
	| anEffectiveExtent |
	anEffectiveExtent := anExtent asPoint.
	tileSize := (anEffectiveExtent x min: anEffectiveExtent y) asFloat.
	super size: anEffectiveExtent.
	self geometry: (BlRoundedRectangleGeometry cornerRadius: self cornerRadius).
	lightBorderAptitude effectWidth: self borderWidth.
	iconElement ifNotNil: [ iconElement size: self iconExtent ].
	self updateTileBackground.
	^ self
]

{ #category : 'private - sizing' }
CFIconTile >> smallSize [
	^ 20
]

{ #category : 'private - appearance' }
CFIconTile >> updateTileBackground [
	self background: (self appearanceBaseColorFor: (backgroundColor ifNil: [ self defaultBackgroundColor ]))
]

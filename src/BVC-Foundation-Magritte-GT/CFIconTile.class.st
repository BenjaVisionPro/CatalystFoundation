"I present icon content inside Foundation's square icon chrome. I am presentation-neutral: callers choose my size and supply an icon that understands #color: and #fitInto:."

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

{ #category : 'sizing' }
CFIconTile >> beSmall [
	^ self size: self smallSize
]

{ #category : 'sizing' }
CFIconTile >> beMedium [
	^ self size: self mediumSize
]

{ #category : 'sizing' }
CFIconTile >> beLarge [
	^ self size: self largeSize
]

{ #category : 'sizing' }
CFIconTile >> size: aNumber [
	tileSize := aNumber asFloat.
	super size: tileSize @ tileSize.
	self geometry: (BlRoundedRectangleGeometry cornerRadius: self cornerRadius).
	lightBorderAptitude effectWidth: self borderWidth.
	iconElement ifNotNil: [ iconElement fitInto: self iconExtent ].
	self background: (self backgroundPaintFor: backgroundColor).
	^ self
]

{ #category : 'accessing' }
CFIconTile >> icon: anIconElement [
	iconElement ifNotNil: [ self removeChild: iconElement ].
	iconElement := anIconElement
		color: Color white;
		fitInto: self iconExtent;
		yourself.
	iconElement constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	self addChild: iconElement.
	^ self
]

{ #category : 'accessing' }
CFIconTile >> backgroundColor: aColor [
	backgroundColor := aColor.
	self background: (self backgroundPaintFor: backgroundColor).
	^ self
]

{ #category : 'private - appearance' }
CFIconTile >> backgroundPaintFor: aColor [
	| aBaseColor |
	aBaseColor := self appearanceBaseColorFor: (aColor ifNil: [ self defaultBackgroundColor ]).
	^ (BlLinearGradientPaint direction: CFInterfaceLighting lightDirection asPoint)
		from: (self gradientShadowFor: aBaseColor)
		to: (self gradientHighlightFor: aBaseColor)
]

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

{ #category : 'private - appearance' }
CFIconTile >> gradientHighlightFor: aColor [
	| strength |
	strength := 0.35.
	^ Color
		r: aColor red + ((1.0 - aColor red) * strength)
		g: aColor green + ((1.0 - aColor green) * strength)
		b: aColor blue + ((1.0 - aColor blue) * strength)
		alpha: aColor alpha
]

{ #category : 'private - appearance' }
CFIconTile >> gradientShadowFor: aColor [
	| strength |
	strength := 0.30.
	^ Color
		r: aColor red * (1.0 - strength)
		g: aColor green * (1.0 - strength)
		b: aColor blue * (1.0 - strength)
		alpha: aColor alpha
]

{ #category : 'private - appearance' }
CFIconTile >> defaultBackgroundColor [
	^ Color r: 140 g: 140 b: 140 range: 255
]

{ #category : 'private - sizing' }
CFIconTile >> smallSize [
	^ 20
]

{ #category : 'private - sizing' }
CFIconTile >> mediumSize [
	^ 28
]

{ #category : 'private - sizing' }
CFIconTile >> largeSize [
	^ 44
]

{ #category : 'private - sizing' }
CFIconTile >> iconExtent [
	| anIconSize |
	anIconSize := tileSize * (20.0 / 28.0).
	^ anIconSize @ anIconSize
]

{ #category : 'private - sizing' }
CFIconTile >> cornerRadius [
	^ tileSize * (7.0 / 28.0)
]

{ #category : 'private - sizing' }
CFIconTile >> borderWidth [
	^ tileSize * (1.5 / 28.0)
]

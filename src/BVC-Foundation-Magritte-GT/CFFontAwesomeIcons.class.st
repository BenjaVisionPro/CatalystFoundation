"
I am the common base class for generated Font Awesome icon factory classes.
Each discovered Font Awesome style is represented by a subclass created on demand by CFFontAwesomeMetadataImporter.
"
Class {
	#name : 'CFFontAwesomeIcons',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'styles' }
CFFontAwesomeIcons class >> availableStyles [
	^ (self subclasses
		collect: [ :each | each styleName ])
		asSortedCollection asArray
]

{ #category : 'instance creation' }
CFFontAwesomeIcons class >> icon: aSelectorSymbol [
	^ self perform: aSelectorSymbol asSymbol
]

{ #category : 'instance creation' }
CFFontAwesomeIcons class >> icon: aSelectorSymbol color: aColor [
	^ (self icon: aSelectorSymbol)
		color: aColor;
		yourself
]

{ #category : 'instance creation' }
CFFontAwesomeIcons class >> icon: aSelectorSymbol size: aSize color: aColor [
	| icon |
	icon := (self icon: aSelectorSymbol)
		color: aColor;
		yourself.
	^ [ icon asElement size: aSize ] asStencil
]

{ #category : 'instance creation' }
CFFontAwesomeIcons class >> iconNamed: aSelector styleKey: aStyleKey width: aWidth height: aHeight paths: pathCollection unicode: aUnicodeString label: aLabelString [
	^ CFFontAwesomeIcon new
		initializeName: aSelector
		styleKey: aStyleKey
		unicode: aUnicodeString
		label: aLabelString
		viewBox: (0 @ 0 extent: aWidth @ aHeight)
		paths: pathCollection
]

{ #category : 'styles' }
CFFontAwesomeIcons class >> style: aStyleName [
	^ Smalltalk
		at: (CFFontAwesomeMetadataImporter styleClassNameFor: aStyleName) asSymbol
		ifAbsent: [ self error: 'No imported Font Awesome style named ', aStyleName printString ]
]

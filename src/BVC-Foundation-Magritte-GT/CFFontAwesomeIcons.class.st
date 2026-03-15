"
I am the common base class for generated Font Awesome icon factory classes.
Each discovered Font Awesome style is represented by a subclass created on demand by CFFontAwesomeMetadataImporter.
"
Class {
	#name : 'CFFontAwesomeIcons',
	#superclass : 'Object',
	#classVars : [
		'Metadata',
		'DefaultStyleName'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'styles' }
CFFontAwesomeIcons class >> availableStyles [
	| styleBaseClass |
	styleBaseClass := self styleName
		ifNil: [ self ]
		ifNotNil: [ self superclass ].
	^ (styleBaseClass subclasses
		collect: [ :each | each styleName ])
		reject: [ :each | each isNil ])
		asSortedCollection asArray
]

{ #category : 'metadata' }
CFFontAwesomeIcons class >> availableIcons [
	^ self defaultStyle availableIcons
]

{ #category : 'metadata' }
CFFontAwesomeIcons class >> availableIconsForStyleNamed: aStyleName [
	^ (self styleOrDefaultNamed: aStyleName) availableIcons
]

{ #category : 'styles' }
CFFontAwesomeIcons class >> defaultStyle [
	^ self style: self defaultStyleName
]

{ #category : 'styles' }
CFFontAwesomeIcons class >> defaultStyleName [
	^ DefaultStyleName
		ifNil: [ self error: 'No default Font Awesome style has been configured' ]
]

{ #category : 'styles' }
CFFontAwesomeIcons class >> defaultStyleName: aStyleName [
	DefaultStyleName := aStyleName
]

{ #category : 'gt extensions' }
CFFontAwesomeIcons class >> gtIconsFor: aView [
	<gtView>
	<gtClassView>
	^ aView list
		title: 'Icons';
		priority: -10;
		items: self availableIcons;
		itemStencil: [ BlElement new
				layout: BlLinearLayout horizontal;
				margin: (BlInsets all: 3);
				constraintsDo: [ :c |
					c vertical fitContent.
					c horizontal matchParent ];
				addChild: (BlElement new size: 64 @ 64) as: #icon;
				addChild: (BrLabel new
							aptitude: BrGlamorousLabelAptitude;
							constraintsDo: [ :c | c linear vertical alignCenter ];
							padding: (BlInsets left: 20 right: 3))
					as: #label ];
		itemDataBinder: [ :anElement :anIcon :anIndex |
			anElement
				replaceChild: (anElement childNamed: #icon)
				with: (anIcon value asElement asScalableElement size: 64 @ 64)
				as: #icon.
			(anElement childNamed: #label) text: anIcon key asString.
			anElement ];
		actionUpdateButtonTooltip: 'Update icon list';
		send: #value
]

{ #category : 'gt extensions' }
CFFontAwesomeIcons class >> gtSpotterForVectorIconFor: aSearch [
	<gtSearch>
	^ aSearch list
		title: 'Vector Icons';
		priority: 1;
		items: [ GtSpotterVectorIconPreview
				library: self
				allIcons: self availableIcons ];
		itemName: #iconSelector;
		filterBySubstring
]

{ #category : 'instance creation' }
CFFontAwesomeIcons class >> icon: aSelectorSymbol [
	self styleName ifNil: [ ^ self defaultStyle perform: aSelectorSymbol asSymbol ].
	^ self perform: aSelectorSymbol asSymbol
]

{ #category : 'instance creation' }
CFFontAwesomeIcons class >> icon: aSelectorSymbol styleName: aStyleName [
	^ (self styleOrDefaultNamed: aStyleName) icon: aSelectorSymbol
]

{ #category : 'instance creation' }
CFFontAwesomeIcons class >> icon: aSelectorSymbol color: aColor [
	^ (self icon: aSelectorSymbol)
		color: aColor;
		yourself
]

{ #category : 'instance creation' }
CFFontAwesomeIcons class >> icon: aSelectorSymbol size: aSize color: aColor [
	(aSize isPoint or: [ aSize respondsTo: #x ]) ifTrue: [
		^ self icon: aSelectorSymbol fitInto: aSize color: aColor ].
	^ self icon: aSelectorSymbol height: aSize color: aColor
]

{ #category : 'instance creation' }
CFFontAwesomeIcons class >> icon: aSelectorSymbol height: aNumber color: aColor [
	| icon |
	icon := (self icon: aSelectorSymbol)
		color: aColor;
		yourself.
	^ [ icon asScalableElementSized: (icon extentForHeight: aNumber) ] asStencil
]

{ #category : 'instance creation' }
CFFontAwesomeIcons class >> icon: aSelectorSymbol width: aNumber color: aColor [
	| icon |
	icon := (self icon: aSelectorSymbol)
		color: aColor;
		yourself.
	^ [ icon asScalableElementSized: (icon extentForWidth: aNumber) ] asStencil
]

{ #category : 'instance creation' }
CFFontAwesomeIcons class >> icon: aSelectorSymbol fitInto: anExtent color: aColor [
	| icon |
	icon := (self icon: aSelectorSymbol)
		color: aColor;
		yourself.
	^ [ icon asScalableElementSized: (icon extentFittingInto: anExtent) ] asStencil
]

{ #category : 'instance creation' }
CFFontAwesomeIcons class >> iconNamed: aSelector styleKey: aStyleKey width: aWidth height: aHeight pathSpecs: pathSpecs unicode: aUnicodeString label: aLabelString [
	^ CFFontAwesomeIcon new
		initializeName: aSelector
		styleKey: aStyleKey
		unicode: aUnicodeString
		label: aLabelString
		viewBox: (0 @ 0 extent: aWidth @ aHeight)
		pathSpecs: pathSpecs
]

{ #category : 'styles' }
CFFontAwesomeIcons class >> loadFromDisc [
	"Point this to your licensed download of the font awesome metadata"

	CFFontAwesomeMetadataImporter
		importFromIconsJsonFile: '/Users/jupiter/Downloads/fontawesome-pro-5.15.4-desktop/metadata/icons.json'
				asFileReference
		packageName: 'BVC-FontAwesome'
		version: '5.15.4'
]

{ #category : 'metadata' }
CFFontAwesomeIcons class >> metadata [
	^ Metadata ifNil: [ Metadata := CFFontAwesomeMetadata new ]
]

{ #category : 'metadata' }
CFFontAwesomeIcons class >> metadata: aMetadata [
	Metadata := aMetadata
]

{ #category : 'styles' }
CFFontAwesomeIcons class >> styleName [
	^ nil
]

{ #category : 'styles' }
CFFontAwesomeIcons class >> style: aStyleName [
	^ Smalltalk
		at: (CFFontAwesomeMetadataImporter styleClassNameFor: aStyleName) asSymbol
		ifAbsent: [ self error: 'No imported Font Awesome style named ', aStyleName printString ]
]

{ #category : 'styles' }
CFFontAwesomeIcons class >> styleNameOrDefault: aStyleName [
	^ aStyleName ifNil: [ self defaultStyleName ]
]

{ #category : 'styles' }
CFFontAwesomeIcons class >> styleOrDefaultNamed: aStyleName [
	^ aStyleName
		ifNil: [ self defaultStyle ]
		ifNotNil: [ self style: aStyleName ]
]

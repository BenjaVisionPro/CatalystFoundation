"
I am the common base class for generated Font Awesome icon factory classes.
Each discovered Font Awesome style is represented by a subclass created on demand by CFFontAwesomeMetadataImporter.
"
Class {
	#name : 'CFFontAwesomeIcons',
	#superclass : 'Object',
	#classVars : [
		'Metadata'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'styles' }
CFFontAwesomeIcons class >> availableStyles [
	^ (self subclasses
		collect: [ :each | each styleName ])
		asSortedCollection asArray
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
	^ [ icon asElement asScalableElement size: aSize ] asStencil
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
CFFontAwesomeIcons class >> style: aStyleName [
	^ Smalltalk
		at: (CFFontAwesomeMetadataImporter styleClassNameFor: aStyleName) asSymbol
		ifAbsent: [ self error: 'No imported Font Awesome style named ', aStyleName printString ]
]

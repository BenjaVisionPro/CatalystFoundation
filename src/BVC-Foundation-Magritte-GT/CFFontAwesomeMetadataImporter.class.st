"
I import Font Awesome metadata from metadata/icons.json using NeoJSON.
I create a style subclass of CFFontAwesomeIcons for each discovered style and compile one class-side method per icon onto the matching style class.
"
Class {
	#name : 'CFFontAwesomeMetadataImporter',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'private - name conversion' }
CFFontAwesomeMetadataImporter class >> camelCaseFromDashed: aString [
	| parts |
	parts := aString findTokens: '-'.
	^ String streamContents: [ :stream |
		parts do: [ :each | stream nextPutAll: each capitalized ] ]
]

{ #category : 'private - compiling' }
CFFontAwesomeMetadataImporter class >> compileAvailableIconsMethodsFrom: selectorsByStyle baseClass: aBaseClass [
	selectorsByStyle keysAndValuesDo: [ :styleName :selectors |
		| styleClass source |
		styleClass := aBaseClass perform: (self styleSelectorFor: styleName).
		source := String streamContents: [ :stream |
			stream
				nextPutAll: 'availableIcons';
				cr;
				tab; nextPutAll: '^ ';
				nextPutAll: ((selectors asSet asSortedCollection asArray) storeString) ].
		styleClass class compile: source classified: 'metadata' ]
]

{ #category : 'private - compiling' }
CFFontAwesomeMetadataImporter class >> compileAvailableStylesMethodOn: aBaseClass [
	| styleNames source |
	styleNames := (aBaseClass subclasses
		collect: [ :each | each styleName ])
		asSortedCollection asArray.

	source := String streamContents: [ :stream |
		stream
			nextPutAll: 'availableStyles';
			cr;
			tab; nextPutAll: '^ ';
			nextPutAll: styleNames storeString ].

	aBaseClass class compile: source classified: 'styles'
]

{ #category : 'private - compiling' }
CFFontAwesomeMetadataImporter class >> compileIconSelector: aSelector iconName: anIconName styleName: aStyleName unicode: aUnicodeString label: aLabelString svgData: svgData into: aStyleClass [
	| width height paths source |
	width := svgData at: 'width'.
	height := svgData at: 'height'.
	paths := self normalizedPathsFrom: (svgData at: 'path').

	source := self
		sourceForIconSelector: aSelector
		iconName: anIconName
		styleName: aStyleName
		width: width
		height: height
		paths: paths
		unicode: aUnicodeString
		label: aLabelString.

	aStyleClass class compile: source classified: 'icons'
]

{ #category : 'private - compiling' }
CFFontAwesomeMetadataImporter class >> compileStyleAccessorFor: aStyleName on: aBaseClass toReturn: aStyleClass [
	| selector source |
	selector := self styleSelectorFor: aStyleName.
	(aBaseClass class includesSelector: selector) ifTrue: [ ^ self ].

	source := String streamContents: [ :stream |
		stream
			nextPutAll: selector asString;
			cr;
			tab; nextPutAll: '^ ';
			nextPutAll: aStyleClass name asString ].

	aBaseClass class compile: source classified: 'styles'
]

{ #category : 'private - compiling' }
CFFontAwesomeMetadataImporter class >> compileStyleMetadataOn: aStyleClass familyName: aFamilyName version: aVersionString styleName: aStyleName [
	(self hasClassSideSelector: #styleName on: aStyleClass)
		ifFalse: [
			aStyleClass class
				compile: 'styleName
	^ ', aStyleName storeString
				classified: 'metadata' ].

	(self hasClassSideSelector: #fontAwesomeFamilyName on: aStyleClass)
		ifFalse: [
			aStyleClass class
				compile: 'fontAwesomeFamilyName
	^ ', aFamilyName storeString
				classified: 'metadata' ].

	(self hasClassSideSelector: #fontAwesomeVersion on: aStyleClass)
		ifFalse: [
			aStyleClass class
				compile: 'fontAwesomeVersion
	^ ', aVersionString storeString
				classified: 'metadata' ]
]

{ #category : 'private - styles' }
CFFontAwesomeMetadataImporter class >> ensureStyleClassFor: aStyleName baseClass: aBaseClass packageName: aPackageName familyName: aFamilyName version: aVersionString [
	| className styleClass |
	className := self styleClassNameFor: aStyleName.
	styleClass := Smalltalk
		at: className asSymbol
		ifAbsent: [
			aBaseClass
				subclass: className asSymbol
				instanceVariableNames: ''
				classVariableNames: ''
				package: aPackageName ].

	self compileStyleAccessorFor: aStyleName on: aBaseClass toReturn: styleClass.
	self compileStyleMetadataOn: styleClass familyName: aFamilyName version: aVersionString styleName: aStyleName.
	^ styleClass
]

{ #category : 'private - testing' }
CFFontAwesomeMetadataImporter class >> hasClassSideSelector: aSelector on: aClass [
	^ aClass class includesSelector: aSelector
]

{ #category : 'importing' }
CFFontAwesomeMetadataImporter class >> importFromIconsJsonFile: aFileReference [
	^ self
		importFromIconsJsonFile: aFileReference
		baseClass: CFFontAwesomeIcons
		packageName: 'BVC-Foundation-Magritte-GT'
		familyName: 'Font Awesome'
		version: 'unknown'
]

{ #category : 'importing' }
CFFontAwesomeMetadataImporter class >> importFromIconsJsonFile: aFileReference baseClass: aBaseClass packageName: aPackageName familyName: aFamilyName version: aVersionString [
	| metadata selectorsByStyle |
	metadata := self readMetadataFrom: aFileReference.
	selectorsByStyle := Dictionary new.

	metadata keysAndValuesDo: [ :iconName :iconData |
		self
			importIconNamed: iconName
			metadata: iconData
			baseClass: aBaseClass
			packageName: aPackageName
			familyName: aFamilyName
			version: aVersionString
			selectorsByStyle: selectorsByStyle ].

	self compileAvailableIconsMethodsFrom: selectorsByStyle baseClass: aBaseClass.
	self compileAvailableStylesMethodOn: aBaseClass.
	^ aBaseClass
]

{ #category : 'importing' }
CFFontAwesomeMetadataImporter class >> importFromIconsJsonPath: aPathString [
	^ self importFromIconsJsonFile: aPathString asFileReference
]

{ #category : 'private - importing' }
CFFontAwesomeMetadataImporter class >> importIconNamed: anIconName metadata: iconData baseClass: aBaseClass packageName: aPackageName familyName: aFamilyName version: aVersionString selectorsByStyle: selectorsByStyle [
	| styles selector unicode label svgByStyle |
	styles := iconData at: 'styles' ifAbsent: [ #() ].
	selector := self selectorForIconName: anIconName.
	unicode := iconData at: 'unicode' ifAbsent: [ '' ].
	label := iconData at: 'label' ifAbsent: [ anIconName ].
	svgByStyle := iconData at: 'svg' ifAbsent: [ Dictionary new ].

	styles do: [ :styleName |
		| styleClass svgData |
		styleClass := self
			ensureStyleClassFor: styleName
			baseClass: aBaseClass
			packageName: aPackageName
			familyName: aFamilyName
			version: aVersionString.

		svgData := svgByStyle at: styleName ifAbsent: [ nil ].
		svgData ifNotNil: [
			self
				compileIconSelector: selector
				iconName: anIconName
				styleName: styleName
				unicode: unicode
				label: label
				svgData: svgData
				into: styleClass.

			(selectorsByStyle at: styleName ifAbsentPut: [ OrderedCollection new ])
				add: selector ] ]
]

{ #category : 'private - name conversion' }
CFFontAwesomeMetadataImporter class >> lowerCamelCaseFromDashed: aString [
	| parts |
	parts := aString findTokens: '-'.
	parts isEmpty ifTrue: [ ^ '' ].

	^ String streamContents: [ :stream |
		stream nextPutAll: parts first.
		parts allButFirst do: [ :each | stream nextPutAll: each capitalized ] ]
]

{ #category : 'private - normalizing' }
CFFontAwesomeMetadataImporter class >> normalizedPathsFrom: rawPathData [
	rawPathData isString ifTrue: [ ^ Array with: rawPathData ].
	rawPathData isArray ifTrue: [ ^ rawPathData ].
	self error: 'Unsupported path payload type: ', rawPathData class name
]

{ #category : 'private - reading' }
CFFontAwesomeMetadataImporter class >> readMetadataFrom: aFileReference [
	^ NeoJSONReader fromString: aFileReference contents
]

{ #category : 'private - name conversion' }
CFFontAwesomeMetadataImporter class >> reservedSelectorNames [
	^ #('self' 'super' 'thisContext' 'nil' 'true' 'false' 'class' 'new' 'basicNew' 'initialize' 'yourself')
]

{ #category : 'private - name conversion' }
CFFontAwesomeMetadataImporter class >> selectorForIconName: anIconName [
	| selectorName |
	selectorName := self lowerCamelCaseFromDashed: anIconName.
	selectorName isEmpty ifTrue: [ self error: 'Empty icon name' ].
	selectorName first isDigit ifTrue: [ selectorName := 'icon', selectorName ].
	(self reservedSelectorNames includes: selectorName)
		ifTrue: [ selectorName := selectorName, 'Icon' ].
	^ selectorName asSymbol
]

{ #category : 'private - source generation' }
CFFontAwesomeMetadataImporter class >> sourceForIconSelector: aSelector iconName: anIconName styleName: aStyleName width: aWidth height: aHeight paths: pathCollection unicode: aUnicodeString label: aLabelString [
	^ String streamContents: [ :stream |
		stream
			nextPutAll: aSelector asString;
			cr;
			tab; nextPutAll: '<script: ''self ';
			nextPutAll: aSelector asString;
			nextPutAll: ' inspect''>';
			cr;
			tab; nextPutAll: '^ self';
			cr;
			tab; tab; nextPutAll: 'iconNamed: #';
			nextPutAll: aSelector asString;
			cr;
			tab; tab; nextPutAll: 'styleKey: ';
			nextPutAll: aStyleName storeString;
			cr;
			tab; tab; nextPutAll: 'width: ';
			nextPutAll: aWidth asString;
			cr;
			tab; tab; nextPutAll: 'height: ';
			nextPutAll: aHeight asString;
			cr;
			tab; tab; nextPutAll: 'paths: ';
			nextPutAll: pathCollection storeString;
			cr;
			tab; tab; nextPutAll: 'unicode: ';
			nextPutAll: aUnicodeString storeString;
			cr;
			tab; tab; nextPutAll: 'label: ';
			nextPutAll: aLabelString storeString ]
]

{ #category : 'private - styles' }
CFFontAwesomeMetadataImporter class >> styleClassNameFor: aStyleName [
	^ 'CFFontAwesome', (self camelCaseFromDashed: aStyleName), 'Icons'
]

{ #category : 'private - styles' }
CFFontAwesomeMetadataImporter class >> styleSelectorFor: aStyleName [
	| selectorName |
	selectorName := self lowerCamelCaseFromDashed: aStyleName.
	(self reservedSelectorNames includes: selectorName)
		ifTrue: [ selectorName := selectorName, 'Style' ].
	^ selectorName asSymbol
]

"
I import Font Awesome metadata from metadata/icons.json using NeoJSON.
I create a style subclass of CFFontAwesomeIcons for each discovered style and compile one class-side method per icon onto the matching style class.
I use XMLDOMParser to read the raw SVG for duotone role and opacity information.
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
		| styleClass source orderedSelectors |
		styleClass := aBaseClass perform: (self styleSelectorFor: styleName).
		orderedSelectors := selectors asSet asSortedCollection asArray.
		source := String streamContents: [ :stream |
			stream
				nextPutAll: 'availableIcons';
				cr;
				tab; nextPutAll: '^ {';
				cr.
			orderedSelectors
				do: [ :each |
					stream
						tab; tab;
						store: each;
						nextPutAll: ' -> (self perform: #';
						nextPutAll: each asString;
						nextPutAll: ')'.
					each == orderedSelectors last ifFalse: [ stream nextPutAll: '.' ].
					stream cr ].
			stream tab; nextPutAll: '}' ].
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
	| width height pathSpecs source |
	width := svgData at: 'width'.
	height := svgData at: 'height'.
	pathSpecs := self normalizePathSpecsFromSvgData: svgData.

	source := self
		sourceForIconSelector: aSelector
		iconName: anIconName
		styleName: aStyleName
		width: width
		height: height
		pathSpecs: pathSpecs
		unicode: aUnicodeString
		label: aLabelString.

	aStyleClass class compile: source classified: 'icons'
]

{ #category : 'private - compiling' }
CFFontAwesomeMetadataImporter class >> compileStyleAccessorFor: aStyleName on: aBaseClass toReturn: aStyleClass packageName: aPackageName [
	| selector source protocol |
	selector := self styleSelectorFor: aStyleName.
	(aBaseClass class includesSelector: selector) ifTrue: [ ^ self ].
	protocol := '*' , aPackageName asLowercase.

	source := String streamContents: [ :stream |
		stream
			nextPutAll: selector asString;
			cr;
			tab; nextPutAll: '^ ';
			nextPutAll: aStyleClass name asString ].

	aBaseClass class compile: source classified: protocol
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

	self
		compileStyleAccessorFor: aStyleName
		on: aBaseClass
		toReturn: styleClass
		packageName: aPackageName.
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
CFFontAwesomeMetadataImporter class >> normalizePathSpecsFromSvgData: svgData [
	| paths rawSvg pathElements secondaryOpacity |
	paths := self normalizedPathsFrom: (svgData at: 'path').
	rawSvg := svgData at: 'raw' ifAbsent: [ '' ].
	pathElements := self pathElementsFromRawSvg: rawSvg.
	secondaryOpacity := self secondaryOpacityFromRawSvg: rawSvg.

	^ (1 to: paths size) collect: [ :index |
		| pathElement className |
		pathElement := pathElements at: index ifAbsent: [ nil ].
		className := self pathClassNameFromElement: pathElement.
		Dictionary new
			at: #path put: (paths at: index);
			at: #role put: (self roleForClassName: className);
			at: #opacity put: (self opacityForClassName: className secondaryOpacity: secondaryOpacity);
			yourself ]
]

{ #category : 'private - normalizing' }
CFFontAwesomeMetadataImporter class >> normalizedPathsFrom: rawPathData [
	rawPathData isString ifTrue: [ ^ Array with: rawPathData ].
	rawPathData isArray ifTrue: [ ^ rawPathData ].
	self error: 'Unsupported path payload type: ', rawPathData class name
]

{ #category : 'private - parsing raw svg' }
CFFontAwesomeMetadataImporter class >> opacityForClassName: aString secondaryOpacity: aNumber [
	(aString notNil and: [ aString includesSubstring: 'fa-secondary' ])
		ifTrue: [ ^ aNumber ].
	^ 1.0
]

{ #category : 'private - parsing raw svg' }
CFFontAwesomeMetadataImporter class >> pathClassNameFromElement: anElement [
	anElement ifNil: [ ^ nil ].
	^ anElement attributeAt: 'class' ifAbsent: [ nil ]
]

{ #category : 'private - parsing raw svg' }
CFFontAwesomeMetadataImporter class >> pathElementsFromRawSvg: rawSvg [
	| document elements |
	rawSvg ifEmpty: [ ^ #() ].
	document := self xmlDocumentFromRawSvg: rawSvg.
	elements := OrderedCollection new.
	document root ifNil: [ ^ elements ].
	document root allElementsDo: [ :each |
		(each isNamed: 'path') ifTrue: [ elements add: each ] ].
	^ elements
]

{ #category : 'private - reading' }
CFFontAwesomeMetadataImporter class >> readMetadataFrom: aFileReference [
	^ NeoJSONReader fromString: aFileReference contents
]

{ #category : 'private - name conversion' }
CFFontAwesomeMetadataImporter class >> reservedSelectorNames [
	^ #('self' 'super' 'thisContext' 'nil' 'true' 'false' 'class' 'new' 'basicNew' 'initialize' 'yourself')
]

{ #category : 'private - normalizing' }
CFFontAwesomeMetadataImporter class >> roleForClassName: aString [
	(aString notNil and: [ aString includesSubstring: 'fa-secondary' ]) ifTrue: [ ^ #secondary ].
	^ #primary
]

{ #category : 'private - parsing raw svg' }
CFFontAwesomeMetadataImporter class >> secondaryOpacityFromRawSvg: rawSvg [
	| document opacity |
	rawSvg ifEmpty: [ ^ 0.4 ].
	document := self xmlDocumentFromRawSvg: rawSvg.
	opacity := 0.4.
	document root ifNil: [ ^ opacity ].
	document root
		allElementsDo: [ :each | 
			((each isNamed: 'style')
				and: [ each contentString includesSubstring: '.fa-secondary{opacity:' ])
				ifTrue: [ | styleText marker start finish numberText |
					styleText := each contentString.
					marker := '.fa-secondary{opacity:'.
					start := styleText findString: marker startingAt: 1.
					start > 0
						ifTrue: [ start := start + marker size.
							finish := styleText findString: '}' startingAt: start.
							finish > 0
								ifTrue: [ numberText := (styleText copyFrom: start to: finish - 1) trimBoth.
									(numberText beginsWith: '.') ifTrue: [ numberText := '0' , numberText ].
									opacity := numberText asNumber ] ] ] ].
	^ opacity
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
CFFontAwesomeMetadataImporter class >> sourceForIconSelector: aSelector iconName: anIconName styleName: aStyleName width: aWidth height: aHeight pathSpecs: pathSpecs unicode: aUnicodeString label: aLabelString [
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
			tab; tab; nextPutAll: 'pathSpecs: ';
			nextPutAll: pathSpecs storeString;
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

{ #category : 'private - parsing raw svg' }
CFFontAwesomeMetadataImporter class >> xmlDocumentFromRawSvg: rawSvg [
	^ XMLDOMParser parse: rawSvg
]

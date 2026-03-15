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

{ #category : 'importing' }
CFFontAwesomeMetadataImporter class >> defaultStyleName [
	^ 'light'
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
		packageName: 'BVC-Foundation-Magritte-GT'
]

{ #category : 'importing' }
CFFontAwesomeMetadataImporter class >> importFromIconsJsonFile: aFileReference baseClass: aBaseClass packageName: aPackageName familyName: aFamilyName [
	^ self
		importFromIconsJsonFile: aFileReference
		baseClass: aBaseClass
		packageName: aPackageName
		familyName: aFamilyName
		version: (self requiredVersionForIconsJsonFile: aFileReference)
]

{ #category : 'importing' }
CFFontAwesomeMetadataImporter class >> importFromIconsJsonFile: aFileReference baseClass: aBaseClass packageName: aPackageName familyName: aFamilyName version: aVersionString [
	| rawMetadata selectorsByStyle fontAwesomeMetadata categoryMap |
	rawMetadata := self readMetadataFrom: aFileReference.
	categoryMap := self readCategoryMapFromIconsJsonFile: aFileReference.
	selectorsByStyle := Dictionary new.
	fontAwesomeMetadata := self
		newMetadataForFamilyName: aFamilyName
		version: aVersionString.

	rawMetadata keysAndValuesDo: [ :iconName :iconData |
		self
			importIconNamed: iconName
			metadata: iconData
			categoryMap: categoryMap
			baseClass: aBaseClass
			packageName: aPackageName
			familyName: aFamilyName
			version: aVersionString
			selectorsByStyle: selectorsByStyle
			fontAwesomeMetadata: fontAwesomeMetadata ].

	self compileAvailableIconsMethodsFrom: selectorsByStyle baseClass: aBaseClass.
	self compileAvailableStylesMethodOn: aBaseClass.

	fontAwesomeMetadata styles: selectorsByStyle keys asSortedCollection asArray.
	aBaseClass metadata: fontAwesomeMetadata.
	aBaseClass defaultStyleName: self defaultStyleName.

	^ aBaseClass
]

{ #category : 'importing' }
CFFontAwesomeMetadataImporter class >> importFromIconsJsonFile: aFileReference packageName: aPackageName [
	^ self
		importFromIconsJsonFile: aFileReference
		baseClass: CFFontAwesomeIcons
		packageName: aPackageName
		familyName: 'Font Awesome Pro'
		version: (self requiredVersionForIconsJsonFile: aFileReference)
]

{ #category : 'importing' }
CFFontAwesomeMetadataImporter class >> importFromIconsJsonFile: aFileReference packageName: aPackageName familyName: aFamilyName [
	^ self
		importFromIconsJsonFile: aFileReference
		baseClass: CFFontAwesomeIcons
		packageName: aPackageName
		familyName: aFamilyName
		version: (self requiredVersionForIconsJsonFile: aFileReference)
]

{ #category : 'importing' }
CFFontAwesomeMetadataImporter class >> importFromIconsJsonFile: aFileReference packageName: aPackageName version: aVersionString [
	^ self
		importFromIconsJsonFile: aFileReference
		baseClass: CFFontAwesomeIcons
		packageName: aPackageName
		familyName: 'Font Awesome Pro'
		version: aVersionString
]

{ #category : 'importing' }
CFFontAwesomeMetadataImporter class >> importFromIconsJsonPath: aPathString [
	^ self importFromIconsJsonFile: aPathString asFileReference
]

{ #category : 'private - importing' }
CFFontAwesomeMetadataImporter class >> importIconNamed: anIconName metadata: iconData categoryMap: categoryMap baseClass: aBaseClass packageName: aPackageName familyName: aFamilyName version: aVersionString selectorsByStyle: selectorsByStyle fontAwesomeMetadata: fontAwesomeMetadata [
	| styles selector unicode label svgByStyle iconMetadata categories |
	styles := iconData at: 'styles' ifAbsent: [ #() ].
	selector := self selectorForIconName: anIconName.
	unicode := iconData at: 'unicode' ifAbsent: [ '' ].
	label := iconData at: 'label' ifAbsent: [ anIconName ].
	svgByStyle := iconData at: 'svg' ifAbsent: [ Dictionary new ].
	categories := categoryMap at: anIconName ifAbsent: [ #() ].

	iconMetadata := self
		newIconMetadataForIconName: anIconName
		iconData: iconData
		selector: selector
		categories: categories
		iconLibraryClass: aBaseClass.
	fontAwesomeMetadata addIconMetadata: iconMetadata.

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

{ #category : 'private - versioning' }
CFFontAwesomeMetadataImporter class >> inferredVersionForIconsJsonFile: aFileReference [
	| pathString separators tokens |
	pathString := self pathStringFor: aFileReference.
	separators := '/\\-_ '.
	tokens := pathString findTokens: separators.
	^ tokens
		detect: [ :each | self isSemanticVersionString: each ]
		ifNone: [ nil ]
]

{ #category : 'private - versioning' }
CFFontAwesomeMetadataImporter class >> isSemanticVersionString: aString [
	| parts |
	parts := aString findTokens: '.'.
	parts size = 3 ifFalse: [ ^ false ].
	^ parts allSatisfy: [ :each | each notEmpty and: [ each allSatisfy: #isDigit ] ]
]

{ #category : 'importing' }
CFFontAwesomeMetadataImporter class >> loadFromDisc [
	^ self
		importFromIconsJsonFile: '/Users/jupiter/Downloads/fontawesome-pro-5.15.4-desktop/metadata/icons.json'
				asFileReference
		baseClass: CFFontAwesomeIcons
		packageName: 'BVC-FontAwesome'
		familyName: 'Font Awesome Pro'
		version: '5.15.4'
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

{ #category : 'private - metadata' }
CFFontAwesomeMetadataImporter class >> newIconMetadataForIconName: anIconName iconData: iconData selector: aSelector categories: categories iconLibraryClass: anIconLibraryClass [
	| searchData terms label |
	searchData := iconData at: 'search' ifAbsent: [ Dictionary new ].
	terms := searchData at: 'terms' ifAbsent: [ #() ].
	label := iconData at: 'label' ifAbsent: [ anIconName ].

	^ CFFontAwesomeIconMetadata new
		selectorSymbol: aSelector;
		fontAwesomeName: anIconName;
		label: label;
		searchTerms: terms;
		styles: (iconData at: 'styles' ifAbsent: [ #() ]);
		categories: categories;
		iconLibraryClass: anIconLibraryClass;
		yourself
]

{ #category : 'private - metadata' }
CFFontAwesomeMetadataImporter class >> newMetadataForFamilyName: aFamilyName version: aVersionString [
	^ CFFontAwesomeMetadata new
		familyName: aFamilyName;
		version: aVersionString;
		yourself
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

{ #category : 'private - versioning' }
CFFontAwesomeMetadataImporter class >> pathStringFor: aFileReference [
	(aFileReference respondsTo: #pathString) ifTrue: [ ^ aFileReference pathString ].
	(aFileReference respondsTo: #fullName) ifTrue: [ ^ aFileReference fullName ].
	^ aFileReference asString
]

{ #category : 'private - categories' }
CFFontAwesomeMetadataImporter class >> readCategoryMapFromIconsJsonFile: aFileReference [
	| categoriesFile |
	categoriesFile := aFileReference parent / 'categories.yml'.
	(categoriesFile exists and: [ categoriesFile isFile ])
		ifFalse: [ ^ Dictionary new ].
	^ self readCategoryMapFromYamlFile: categoriesFile
]

{ #category : 'private - categories' }
CFFontAwesomeMetadataImporter class >> readCategoryMapFromYamlFile: aFileReference [
	| categoryMap lines currentCategoryKey currentCategoryLabel insideIcons |
	categoryMap := Dictionary new.
	lines := aFileReference contents lines.
	currentCategoryKey := nil.
	currentCategoryLabel := nil.
	insideIcons := false.

	lines do: [ :rawLine |
		| line trimmed indent iconName categories |
		line := rawLine copyUpTo: $#.
		trimmed := line trimBoth.
		trimmed isEmpty ifTrue: [
			insideIcons := false ] ifFalse: [
			indent := line size - line trimLeft size.
			(indent = 0 and: [ trimmed last = $: ]) ifTrue: [
				currentCategoryKey := trimmed allButLast.
				currentCategoryLabel := currentCategoryKey.
				insideIcons := false ] ifFalse: [
				(indent = 2 and: [ trimmed beginsWith: 'label:' ]) ifTrue: [
					currentCategoryLabel := self yamlScalarValueFrom: (trimmed allButFirst: 'label:' size) ] ifFalse: [
					(indent = 2 and: [ trimmed = 'icons:' ]) ifTrue: [
						insideIcons := true ] ifFalse: [
						(insideIcons and: [ indent >= 4 and: [ trimmed beginsWith: '- ' ] ]) ifTrue: [
							iconName := self yamlScalarValueFrom: (trimmed allButFirst: 2).
							categories := categoryMap at: iconName ifAbsentPut: [ OrderedCollection new ].
							(categories includes: currentCategoryLabel) ifFalse: [
								categories add: currentCategoryLabel ] ] ] ] ] ] ].

	categoryMap keysAndValuesDo: [ :key :value |
		categoryMap at: key put: value asArray ].
	^ categoryMap
]

{ #category : 'private - reading' }
CFFontAwesomeMetadataImporter class >> readMetadataFrom: aFileReference [
	^ NeoJSONReader fromString: aFileReference contents
]

{ #category : 'private - versioning' }
CFFontAwesomeMetadataImporter class >> requiredVersionForIconsJsonFile: aFileReference [
	^ self inferredVersionForIconsJsonFile: aFileReference
		ifNil: [ self error: 'Font Awesome version was not provided and could not be inferred from the metadata file path' ]
]

{ #category : 'private - name conversion' }
CFFontAwesomeMetadataImporter class >> reservedSelectorNames [
	^ #('comment' 'self' 'super' 'thisContext' 'nil' 'true' 'false' 'class' 'new' 'basicNew' 'initialize' 'yourself')
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

{ #category : 'private - categories' }
CFFontAwesomeMetadataImporter class >> yamlScalarValueFrom: aString [
	| value |
	value := aString trimBoth.
	((value beginsWith: '''') and: [ value endsWith: '''' ])
		ifTrue: [ ^ value copyFrom: 2 to: value size - 1 ].
	((value beginsWith: '"') and: [ value endsWith: '"' ])
		ifTrue: [ ^ value copyFrom: 2 to: value size - 1 ].
	^ value
]

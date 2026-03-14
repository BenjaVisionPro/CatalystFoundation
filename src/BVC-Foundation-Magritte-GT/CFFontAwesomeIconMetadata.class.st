Class {
	#name : 'CFFontAwesomeIconMetadata',
	#superclass : 'Object',
	#instVars : [
		'selectorSymbol',
		'fontAwesomeName',
		'label',
		'searchTerms',
		'styles',
		'categories'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> categories [
	^ categories
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> categories: aCollection [
	categories := aCollection asArray
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> fontAwesomeName [
	^ fontAwesomeName
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> fontAwesomeName: aString [
	fontAwesomeName := aString
]

{ #category : 'initialization' }
CFFontAwesomeIconMetadata >> initialize [
	super initialize.
	searchTerms := #().
	styles := #().
	categories := #()
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> label [
	^ label
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> label: aString [
	label := aString
]

{ #category : 'searching' }
CFFontAwesomeIconMetadata >> matchesSearchText: aString [
	| query |
	query := aString asLowercase.
	^ ({ self selectorSymbol asString.
		self fontAwesomeName ifNil: [ '' ].
		self label ifNil: [ '' ] }
		, self searchTerms
		, self categories)
			anySatisfy: [ :each | (each asString asLowercase includesSubstring: query) ]
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> searchTerms [
	^ searchTerms
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> searchTerms: aCollection [
	searchTerms := aCollection asArray
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> selectorSymbol [
	^ selectorSymbol
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> selectorSymbol: aSymbol [
	selectorSymbol := aSymbol
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> styles [
	^ styles
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> styles: aCollection [
	styles := aCollection asArray
]

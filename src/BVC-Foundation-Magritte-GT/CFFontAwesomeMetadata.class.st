Class {
	#name : 'CFFontAwesomeMetadata',
	#superclass : 'Object',
	#instVars : [
		'familyName',
		'version',
		'styles',
		'iconsBySelector'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'adding' }
CFFontAwesomeMetadata >> addIconMetadata: anIconMetadata [
	iconsBySelector at: anIconMetadata selectorSymbol put: anIconMetadata
]

{ #category : 'accessing' }
CFFontAwesomeMetadata >> allIconMetadata [
	^ iconsBySelector values asArray
]

{ #category : 'accessing' }
CFFontAwesomeMetadata >> familyName [
	^ familyName
]

{ #category : 'accessing' }
CFFontAwesomeMetadata >> familyName: aString [
	familyName := aString
]

{ #category : 'searching' }
CFFontAwesomeMetadata >> filterIconsMatching: aString [
	^ self searchIconsMatching: aString
]

{ #category : 'gt extensions' }
CFFontAwesomeMetadata >> gtSearchForFontAwesomeIconsFor: aSearch [
	<gtSearch>
	^ aSearch list
		title: 'Font Awesome Icons';
		priority: 5;
		items: [ self allIconMetadata ];
		itemsLimit: Float infinity;
		itemName: [ :each | each searchableText ];
		send: [ :each :step :search | each ];
		filterBySubstringsWith: [ :aSearchFilter :aSpotterContext |
			aSearchFilter
				withCharacterSplitter;
				beCaseInsensitive ];
		wantsToDisplayOnEmptyQuery: false;
		yourself
]

{ #category : 'accessing' }
CFFontAwesomeMetadata >> iconMetadataAt: aSelectorSymbol [
	^ iconsBySelector at: aSelectorSymbol ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CFFontAwesomeMetadata >> iconsBySelector [
	^ iconsBySelector
]

{ #category : 'initialization' }
CFFontAwesomeMetadata >> initialize [
	super initialize.
	styles := #().
	iconsBySelector := Dictionary new
]

{ #category : 'searching' }
CFFontAwesomeMetadata >> queryTermsFor: aString [
	^ ((aString ifNil: [ '' ]) asLowercase findTokens: Character space asString)
		reject: [ :each | each isEmpty ]
]

{ #category : 'searching' }
CFFontAwesomeMetadata >> searchIconsMatching: aString [
	| terms |
	terms := self queryTermsFor: aString.
	terms isEmpty ifTrue: [ ^ self allIconMetadata ].
	^ (self allIconMetadata
		select: [ :each | each matchesAllSearchTerms: terms ])
		asSortedCollection: [ :a :b |
			| sa sb |
			sa := a scoreForSearchTerms: terms.
			sb := b scoreForSearchTerms: terms.
			sa = sb
				ifTrue: [ a selectorSymbol asString <= b selectorSymbol asString ]
				ifFalse: [ sa > sb ] ]
]

{ #category : 'accessing' }
CFFontAwesomeMetadata >> styles [
	^ styles
]

{ #category : 'accessing' }
CFFontAwesomeMetadata >> styles: aCollection [
	styles := aCollection asArray
]

{ #category : 'accessing' }
CFFontAwesomeMetadata >> version [
	^ version
]

{ #category : 'accessing' }
CFFontAwesomeMetadata >> version: aString [
	version := aString
]

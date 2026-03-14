Class {
	#name : 'CFFontAwesomeIconMetadata',
	#superclass : 'Object',
	#instVars : [
		'selectorSymbol',
		'fontAwesomeName',
		'label',
		'searchTerms',
		'styles',
		'categories',
		'iconLibraryClass'
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

{ #category : 'gt extensions' }
CFFontAwesomeIconMetadata >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 10;
		items: [ {
			{'Selector'. self selectorSymbol asString}.
			{'Font Awesome Name'. self fontAwesomeName ifNil: [ '' ]}.
			{'Title'. self label ifNil: [ '' ]}.
			{'Styles'. ' , ' join: self styles}.
			{'Categories'. ' , ' join: self categories} } ];
		column: 'Field' text: [ :each | each first ];
		column: 'Value' text: [ :each | each second ]
]

{ #category : 'gt extensions' }
CFFontAwesomeIconMetadata >> gtLiveFor: aView [
	<gtView>
	^ aView explicit
		title: 'Live';
		priority: 0;
		stencil: [
			GtInspectorElementLiveViewContainer new
				element: (((self iconLibraryClass style: self preferredStyleName)
					icon: self selectorSymbol
					size: 64 @ 64
					color: Color black) asElement);
				clipChildren: false ]
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> gtDisplayText [
	^ self label ifNil: [ self selectorSymbol asString ]
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> iconLibraryClass [
	^ iconLibraryClass ifNil: [ CFFontAwesomeIcons ]
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> iconLibraryClass: aClass [
	iconLibraryClass := aClass
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
CFFontAwesomeIconMetadata >> matchesAllSearchTerms: aCollection [
	| lowered |
	lowered := self searchableStrings collect: [ :each | each asLowercase ].
	^ aCollection allSatisfy: [ :term |
		lowered anySatisfy: [ :each | each includesSubstring: term ] ]
]

{ #category : 'searching' }
CFFontAwesomeIconMetadata >> matchesSearchText: aString [
	^ self matchesAllSearchTerms: { aString asLowercase }
]

{ #category : 'accessing' }
CFFontAwesomeIconMetadata >> preferredStyleName [
	(styles includes: 'regular') ifTrue: [ ^ 'regular' ].
	styles isEmpty ifTrue: [ ^ 'regular' ].
	^ styles first
]

{ #category : 'searching' }
CFFontAwesomeIconMetadata >> scoreForSearchTerms: aCollection [
	| selector name title score |
	selector := self selectorSymbol asString asLowercase.
	name := (self fontAwesomeName ifNil: [ '' ]) asLowercase.
	title := (self label ifNil: [ '' ]) asLowercase.
	score := 0.
	aCollection do: [ :term |
		selector = term ifTrue: [ score := score + 1000 ].
		(selector beginsWith: term) ifTrue: [ score := score + 300 ].
		(title beginsWith: term) ifTrue: [ score := score + 200 ].
		((selector includesSubstring: term)
			or: [ name includesSubstring: term ]
			or: [ title includesSubstring: term ]) ifTrue: [ score := score + 50 ].
		(self searchTerms anySatisfy: [ :each | each asString asLowercase includesSubstring: term ]) ifTrue: [ score := score + 20 ].
		(self categories anySatisfy: [ :each | each asString asLowercase includesSubstring: term ]) ifTrue: [ score := score + 10 ] ].
	^ score
]

{ #category : 'searching' }
CFFontAwesomeIconMetadata >> searchableStrings [
	^ ({ self selectorSymbol asString.
		self fontAwesomeName ifNil: [ '' ].
		self label ifNil: [ '' ] }
		, self searchTerms
		, self categories)
		collect: [ :each | each asString ]
]

{ #category : 'searching' }
CFFontAwesomeIconMetadata >> searchableText [
	^ ' ' join: self searchableStrings
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

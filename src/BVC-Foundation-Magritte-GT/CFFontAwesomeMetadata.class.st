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

{ #category : 'searching' }
CFFontAwesomeMetadata >> filterIconsMatching: aString [
	| query |
	query := aString trimBoth asLowercase.
	query isEmpty ifTrue: [ ^ self allIconMetadata ].
	^ self allIconMetadata
		select: [ :each | each matchesSearchText: query ]
]

{ #category : 'accessing' }
CFFontAwesomeMetadata >> familyName [
	^ familyName
]

{ #category : 'accessing' }
CFFontAwesomeMetadata >> familyName: aString [
	familyName := aString
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

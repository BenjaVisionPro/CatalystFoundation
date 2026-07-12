Class {
	#name : 'CFConfigurationMethodAsset',
	#superclass : 'CFConfigurationAsset',
	#instVars : [
		'sourceClass',
		'selector'
	],
	#category : 'BVC-Foundation-Config-Library',
	#package : 'BVC-Foundation-Config-Library'
}

{ #category : 'instance creation' }
CFConfigurationMethodAsset class >> fromPragma: aPragma [
	| sourceClass selector returnPragma configurationClass |
	aPragma methodClass isMeta ifFalse: [ ^ nil ].
	sourceClass := aPragma methodClass instanceSide.
	selector := aPragma methodSelector.
	(sourceClass class includesSelector: selector)
		ifFalse: [ ^ nil ].
	returnPragma := aPragma method pragmas
		detect: [ :each | each selector = #return: ]
		ifNone: [ nil ].
	configurationClass := returnPragma
		ifNil: [ nil ]
		ifNotNil: [ Smalltalk at: (returnPragma argumentAt: 1) ifAbsent: [ nil ] ].
	^ self new
		sourceClass: sourceClass;
		selector: selector;
		configurationClass: configurationClass;
		label: sourceClass name asString , ' >> ' , selector asString;
		yourself
]

{ #category : 'discovering' }
CFConfigurationMethodAsset class >> allDiscovered [
	^ (Pragma allNamed: #cfConfiguration)
		collect: [ :each | self fromPragma: each ]
		thenReject: #isNil
]

{ #category : 'materializing' }
CFConfigurationMethodAsset >> materialize [
	^ self validateMaterializedConfiguration: (sourceClass perform: selector)
]

{ #category : 'accessing' }
CFConfigurationMethodAsset >> selector [
	^ selector
]

{ #category : 'accessing' }
CFConfigurationMethodAsset >> selector: aSymbol [
	selector := aSymbol
]

{ #category : 'accessing' }
CFConfigurationMethodAsset >> sourceClass [
	^ sourceClass
]

{ #category : 'accessing' }
CFConfigurationMethodAsset >> sourceClass: aClass [
	sourceClass := aClass
]

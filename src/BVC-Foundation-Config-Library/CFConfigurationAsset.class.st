Class {
	#name : 'CFConfigurationAsset',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'configurationClass'
	],
	#category : 'BVC-Foundation-Config-Library',
	#package : 'BVC-Foundation-Config-Library'
}

{ #category : 'accessing' }
CFConfigurationAsset >> configurationClass [
	^ configurationClass
]

{ #category : 'accessing' }
CFConfigurationAsset >> configurationClass: aClassOrNil [
	configurationClass := aClassOrNil
]

{ #category : 'materializing' }
CFConfigurationAsset >> materialize [
	self subclassResponsibility
]

{ #category : 'private - materializing' }
CFConfigurationAsset >> validateMaterializedConfiguration: aConfiguration [
	(aConfiguration isKindOf: CFConfiguration)
		ifFalse: [ self error: 'Configuration assets must materialize a CFConfiguration instance.' ].
	(configurationClass notNil and: [ (aConfiguration isKindOf: configurationClass) not ])
		ifTrue: [ self error: 'The materialized configuration does not match its declared configuration class.' ].
	^ aConfiguration
]

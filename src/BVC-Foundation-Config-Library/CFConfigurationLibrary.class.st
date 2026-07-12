Class {
	#name : 'CFConfigurationLibrary',
	#superclass : 'Object',
	#instVars : [
		'assets'
	],
	#category : 'BVC-Foundation-Config-Library',
	#package : 'BVC-Foundation-Config-Library'
}

{ #category : 'instance creation' }
CFConfigurationLibrary class >> discovered [
	^ self new
		addAll: CFConfigurationMethodAsset allDiscovered;
		yourself
]

{ #category : 'adding' }
CFConfigurationLibrary >> add: aConfigurationAsset [
	assets add: aConfigurationAsset.
	^ aConfigurationAsset
]

{ #category : 'adding' }
CFConfigurationLibrary >> addAll: aCollection [
	aCollection do: [ :each | self add: each ]
]

{ #category : 'accessing' }
CFConfigurationLibrary >> assets [
	^ assets
]

{ #category : 'initialization' }
CFConfigurationLibrary >> initialize [
	super initialize.
	assets := OrderedCollection new
]

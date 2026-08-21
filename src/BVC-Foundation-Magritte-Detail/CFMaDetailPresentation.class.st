Class {
	#name : 'CFMaDetailPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'groupConfigurations'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPresentation >> initialize [
	super initialize.
	groupConfigurations := Dictionary new
]

{ #category : 'configuration' }
CFMaDetailPresentation >> group: aGroup configure: aBlock [
	| aConfiguration |
	aConfiguration := self groupConfigurationFor: aGroup.
	aBlock cull: aConfiguration.
	^ self
]

{ #category : 'configuration' }
CFMaDetailPresentation >> groupConfigurationFor: aGroup [
	^ groupConfigurations
		at: aGroup
		ifAbsentPut: [ CFMaDetailGroupConfiguration new ]
]

{ #category : 'configuration' }
CFMaDetailPresentation >> groupConfigurationAt: aGroup ifAbsent: aBlock [
	^ groupConfigurations at: aGroup ifAbsent: aBlock
]

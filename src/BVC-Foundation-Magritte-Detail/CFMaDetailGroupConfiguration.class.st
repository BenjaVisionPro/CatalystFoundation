"I hold Detail presentation configuration for one level of Foundation's grouping hierarchy. Magritte supplies the first level as a group; Foundation categories recursively extend the same hierarchy. I contain configuration only and no live UI state."

Class {
	#name : 'CFMaDetailGroupConfiguration',
	#superclass : 'Object',
	#instVars : [
		'categories'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailGroupConfiguration >> initialize [
	super initialize.
	categories := Dictionary new
]

{ #category : 'configuration' }
CFMaDetailGroupConfiguration >> category: aCategory configure: aBlock [
	| aConfiguration |
	aConfiguration := self categoryConfigurationFor: aCategory.
	aBlock cull: aConfiguration.
	^ self
]

{ #category : 'configuration' }
CFMaDetailGroupConfiguration >> categoryConfigurationFor: aCategory [
	^ categories
		at: aCategory
		ifAbsentPut: [ self class new ]
]

{ #category : 'configuration' }
CFMaDetailGroupConfiguration >> categoryConfigurationAt: aCategory ifAbsent: aBlock [
	^ categories at: aCategory ifAbsent: aBlock
]

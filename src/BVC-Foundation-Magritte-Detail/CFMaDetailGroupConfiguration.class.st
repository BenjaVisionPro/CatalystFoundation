"I configure a Detail group. Magritte groups form the first level; Foundation categories extend the same group hierarchy recursively. I contain configuration only and no live UI state."

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


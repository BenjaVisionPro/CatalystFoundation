Class {
	#name : 'CFMaDetailCategoryConfiguration',
	#superclass : 'Object',
	#instVars : [
		'arrangement',
		'categories'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailCategoryConfiguration >> initialize [
	super initialize.
	arrangement := CFMaDetailSectionCategoryArrangement new.
	categories := Dictionary new
]

{ #category : 'configuration' }
CFMaDetailCategoryConfiguration >> asTabs [
	arrangement := CFMaDetailTabCategoryArrangement new
]

{ #category : 'configuration' }
CFMaDetailCategoryConfiguration >> asAccordions [
	arrangement := CFMaDetailAccordionCategoryArrangement new
]

{ #category : 'configuration' }
CFMaDetailCategoryConfiguration >> asSections [
	arrangement := CFMaDetailSectionCategoryArrangement new
]

{ #category : 'accessing' }
CFMaDetailCategoryConfiguration >> arrangement [
	^ arrangement
]

{ #category : 'configuration' }
CFMaDetailCategoryConfiguration >> category: aCategory configure: aBlock [
	| aConfiguration |
	aConfiguration := self categoryConfigurationFor: aCategory.
	aBlock cull: aConfiguration.
	^ self
]

{ #category : 'configuration' }
CFMaDetailCategoryConfiguration >> categoryConfigurationFor: aCategory [
	^ categories
		at: aCategory
		ifAbsentPut: [ CFMaDetailCategoryConfiguration new ]
]

{ #category : 'configuration' }
CFMaDetailCategoryConfiguration >> categoryConfigurationAt: aCategory ifAbsent: aBlock [
	^ categories at: aCategory ifAbsent: aBlock
]

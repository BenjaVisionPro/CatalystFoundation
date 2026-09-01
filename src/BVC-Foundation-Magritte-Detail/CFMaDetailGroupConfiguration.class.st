"I configure a Detail group. Magritte groups form the first level; Foundation categories extend the same group hierarchy recursively. I contain configuration only and no live UI state."

Class {
	#name : 'CFMaDetailGroupConfiguration',
	#superclass : 'Object',
	#instVars : [
		'categories',
		'presentation',
		'reservedAccessorySlots',
		'labelVisible'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailGroupConfiguration >> initialize [
	super initialize.
	categories := Dictionary new.
	reservedAccessorySlots := 0.
	labelVisible := true.
	presentation := CFMaDetailDefaultGroupConfiguration new
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


{ #category : 'configuration - presentation' }
CFMaDetailGroupConfiguration >> hideLabel [
	labelVisible := false.
	^ self
]

{ #category : 'accessing' }
CFMaDetailGroupConfiguration >> labelVisible [
	^ labelVisible
]

{ #category : 'configuration - presentation' }
CFMaDetailGroupConfiguration >> beTabs [
	presentation := CFMaDetailTabsConfiguration new.
	^ presentation
]

{ #category : 'configuration - presentation' }
CFMaDetailGroupConfiguration >> beButtonBar [
	presentation := CFMaDetailButtonBarConfiguration new.
	^ presentation
]

{ #category : 'configuration - presentation' }
CFMaDetailGroupConfiguration >> beIconButtonBar [
	presentation := CFMaDetailButtonBarConfiguration new beIconOnly.
	^ presentation
]

{ #category : 'accessing' }
CFMaDetailGroupConfiguration >> presentation [
	^ presentation
]


{ #category : 'configuration - layout' }
CFMaDetailGroupConfiguration >> reserveAccessorySlots: aNumber [
	self
		assert: [ aNumber isInteger and: [ aNumber >= 0 ] ]
		description: [ 'The number of reserved accessory slots must be a non-negative integer' ].
	reservedAccessorySlots := aNumber.
	^ self
]

{ #category : 'accessing' }
CFMaDetailGroupConfiguration >> reservedAccessorySlots [
	^ reservedAccessorySlots
]

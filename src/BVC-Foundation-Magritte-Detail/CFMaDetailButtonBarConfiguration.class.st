"I configure a Detail group to present its immediate child groups with a button bar. I contain configuration only and no live UI state."

Class {
	#name : 'CFMaDetailButtonBarConfiguration',
	#superclass : 'Object',
	#instVars : [
		'icons',
		'iconOnly'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailButtonBarConfiguration >> initialize [
	super initialize.
	icons := Dictionary new.
	iconOnly := false
]

{ #category : 'configuration' }
CFMaDetailButtonBarConfiguration >> beIconOnly [
	iconOnly := true.
	^ self
]

{ #category : 'configuration' }
CFMaDetailButtonBarConfiguration >> icon: anIcon for: aCategory [
	icons at: aCategory put: anIcon.
	^ self
]

{ #category : 'accessing' }
CFMaDetailButtonBarConfiguration >> iconFor: aCategory [
	^ icons
		at: aCategory
		ifAbsent: [ self error: 'An icon-only button bar requires an icon for every child group' ]
]

{ #category : 'testing' }
CFMaDetailButtonBarConfiguration >> isIconOnly [
	^ iconOnly
]

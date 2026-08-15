"I am responsible for a finite Foundation flow list whose surrounding form owns scrolling."

Class {
	#name : 'CFMaFiniteFlowList',
	#superclass : 'BrFlowList',
	#instVars : [
		'minimumItemWidth',
		'itemSpacing',
		'singleColumn'
	],
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'initialization' }
CFMaFiniteFlowList >> initialize [
	super initialize.

	minimumItemWidth := 280.
	itemSpacing := 8.
	singleColumn := false.

	self
		aptitude: CFMaFiniteFlowListAptitude new;
		beFocusable;
		hMatchParent;
		vFitContent;
		when: BlElementExtentChangedEvent
			do: [ :anEvent | anEvent currentTarget updateResponsiveItemWidths ]
]

{ #category : 'accessing' }
CFMaFiniteFlowList >> itemSpacing [
	^ itemSpacing
]

{ #category : 'accessing' }
CFMaFiniteFlowList >> itemSpacing: aNumber [
	itemSpacing := aNumber.
	self updateResponsiveItemWidths
]

{ #category : 'accessing' }
CFMaFiniteFlowList >> minimumItemWidth [
	^ minimumItemWidth
]

{ #category : 'accessing' }
CFMaFiniteFlowList >> minimumItemWidth: aNumber [
	minimumItemWidth := aNumber.
	self updateResponsiveItemWidths
]


{ #category : 'accessing' }
CFMaFiniteFlowList >> singleColumn [
	^ singleColumn
]

{ #category : 'accessing' }
CFMaFiniteFlowList >> singleColumn: aBoolean [
	singleColumn := aBoolean.
	self updateResponsiveItemWidths
]

{ #category : 'private - layout' }
CFMaFiniteFlowList >> responsiveContentElement [
	self aptitudeDo: [ :anAptitude |
		(anAptitude isKindOf: CFMaFiniteFlowListAptitude)
			ifTrue: [ ^ anAptitude contentElement ] ].
	^ nil
]

{ #category : 'private - layout' }
CFMaFiniteFlowList >> responsiveItemWidthFor: anAvailableWidth [
	| aColumnCount |
	anAvailableWidth <= 0 ifTrue: [ ^ minimumItemWidth ].
	singleColumn ifTrue: [ ^ anAvailableWidth ].

	aColumnCount := (anAvailableWidth / (minimumItemWidth + itemSpacing)) floor max: 1.
	^ ((anAvailableWidth / aColumnCount) - itemSpacing) max: minimumItemWidth
]

{ #category : 'layout' }
CFMaFiniteFlowList >> updateResponsiveItemWidths [
	| aContentElement anItemWidth |
	self width <= 0 ifTrue: [ ^ self ].

	aContentElement := self responsiveContentElement.
	aContentElement ifNil: [ ^ self ].

	anItemWidth := self responsiveItemWidthFor: self width.
	aContentElement children do: [ :anItemElement |
		anItemElement hExact: anItemWidth ].
]

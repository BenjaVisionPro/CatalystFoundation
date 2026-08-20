Class {
	#name : 'CFMaSettingsRowLayout',
	#superclass : 'BlLayout',
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'constraints' }
CFMaSettingsRowLayout class >> constraints [
	^ BlLayoutCommonConstraints new
]

{ #category : 'private - measurement' }
CFMaSettingsRowLayout >> measurePrimaryLine: aPrimaryLine with: anExtentSpec width: aWidth [
	| aParentSpec |
	aPrimaryLine ifNil: [ ^ self ].
	aParentSpec := (BlMeasurementSpec exact: (aWidth max: 0))
		@ BlMeasurementSpec unspecified.
	self
		measureChild: aPrimaryLine
		parentSpec: aParentSpec
]

{ #category : 'private - measurement' }
CFMaSettingsRowLayout >> measureComment: aComment with: anExtentSpec width: aWidth [
	| aParentSpec |
	aComment ifNil: [ ^ self ].
	aParentSpec := (BlMeasurementSpec exact: (aWidth max: 0))
		@ BlMeasurementSpec unspecified.
	self
		measureChild: aComment
		parentSpec: aParentSpec
]

{ #category : 'private - geometry' }
CFMaSettingsRowLayout >> hasFreeHorizontalSpaceIn: aRow [
	^ aRow flexibleSpaceElement
		ifNil: [ false ]
		ifNotNil: [ aRow flexibleSpaceElement measuredWidth > 0 ]
]

{ #category : 'private - geometry' }
CFMaSettingsRowLayout >> fixedWidthFor: aRow [
	| iconWidth actionsWidth |
	iconWidth := aRow iconElement
		ifNil: [ 0 ]
		ifNotNil: [ aRow iconElement measuredWidth + aRow iconGap ].
	actionsWidth := aRow actionsElement measuredWidth > 0
		ifTrue: [ aRow actionsElement measuredWidth + aRow actionsGap ]
		ifFalse: [ 0 ].
	^ iconWidth + actionsWidth
]

{ #category : 'private - geometry' }
CFMaSettingsRowLayout >> balancedColumnWidthFor: aRow contentWidth: aContentWidth [
	| flexibleWidth gutter |
	gutter := aRow editorElement ifNil: [ 0 ] ifNotNil: [ aRow wrappedColumnGap ].
	flexibleWidth := (aContentWidth - (self fixedWidthFor: aRow) - gutter) max: 0.
	^ flexibleWidth / 2
]

{ #category : 'private - measurement' }
CFMaSettingsRowLayout >> resetResponsiveWidthConstraintsFor: aRow [
	aRow labelElement ifNotNil: [ :anElement |
		anElement constraintsDo: [ :c | c maxWidth: Float infinity ] ].
	aRow editorElement ifNotNil: [ :anElement |
		anElement constraintsDo: [ :c | c maxWidth: Float infinity ] ]
]

{ #category : 'private - measurement' }
CFMaSettingsRowLayout >> constrainResponsiveColumnsFor: aRow contentWidth: aContentWidth [
	| columnWidth |
	columnWidth := self balancedColumnWidthFor: aRow contentWidth: aContentWidth.
	aRow labelElement ifNotNil: [ :anElement |
		anElement constraintsDo: [ :c | c maxWidth: columnWidth ] ].
	aRow editorElement ifNotNil: [ :anElement |
		anElement constraintsDo: [ :c | c maxWidth: columnWidth ] ]
]

{ #category : 'private - geometry' }
CFMaSettingsRowLayout >> commentGeometryFor: aRow contentWidth: aContentWidth [
	| comment iconWidth actionsWidth commentWidth commentY hasFreeHorizontalSpace |
	comment := aRow commentElement.
	comment ifNil: [ ^ { 0. 0 } ].

	iconWidth := aRow iconElement
		ifNil: [ 0 ]
		ifNotNil: [ aRow iconElement measuredWidth + aRow iconGap ].
	actionsWidth := aRow actionsElement measuredWidth > 0
		ifTrue: [ aRow actionsElement measuredWidth + aRow actionsGap ]
		ifFalse: [ 0 ].
	hasFreeHorizontalSpace := self hasFreeHorizontalSpaceIn: aRow.

	commentWidth := hasFreeHorizontalSpace
		ifTrue: [ aContentWidth - iconWidth - actionsWidth ]
		ifFalse: [ self balancedColumnWidthFor: aRow contentWidth: aContentWidth ].
	commentWidth := (commentWidth - aRow commentLeftInset) max: 0.
	commentY := (aRow labelElement
		ifNil: [ 0 ]
		ifNotNil: [ aRow labelElement measuredHeight ]) + aRow commentTopGap.
	^ { commentWidth. commentY }
]

{ #category : 'measure' }
CFMaSettingsRowLayout >> measure: aRow with: anExtentSpec [
	| primaryLine comment padding measuredWidth contentWidth geometry commentWidth commentY contentHeight |
	primaryLine := aRow primaryLineElement.
	comment := aRow commentElement.
	padding := aRow padding.

	measuredWidth := anExtentSpec widthSpec sizeFor: padding width.
	contentWidth := (measuredWidth - padding width) max: 0.

	"Always begin from the children's native width contracts. This makes widening
	reversible after a previous constrained pass."
	self resetResponsiveWidthConstraintsFor: aRow.
	self measurePrimaryLine: primaryLine with: anExtentSpec width: contentWidth.

	"When the primary line has no flexible space left, description and editor
	become equal columns separated by the wrapped gutter. The same rule applies
	to every row; it is derived solely from the measured horizontal layout."
	comment ifNotNil: [
		(self hasFreeHorizontalSpaceIn: aRow) ifFalse: [
			self constrainResponsiveColumnsFor: aRow contentWidth: contentWidth.
			self measurePrimaryLine: primaryLine with: anExtentSpec width: contentWidth ] ].

	geometry := self commentGeometryFor: aRow contentWidth: contentWidth.
	commentWidth := geometry first.
	commentY := geometry second.
	self measureComment: comment with: anExtentSpec width: commentWidth.

	contentHeight := primaryLine ifNil: [ 0 ] ifNotNil: [ primaryLine measuredHeight ].
	comment ifNotNil: [
		contentHeight := contentHeight max: (commentY + comment measuredHeight) ].

	aRow measuredExtent:
		(anExtentSpec sizeFor: measuredWidth @ (contentHeight + padding height))
]

{ #category : 'layout' }
CFMaSettingsRowLayout >> layout: aRow in: aRectangle context: aBlElementBoundsUpdateContext [
	| primaryLine comment padding contentBounds geometry commentWidth commentY commentX |
	primaryLine := aRow primaryLineElement.
	comment := aRow commentElement.
	padding := aRow padding.
	contentBounds := padding inset: (0 @ 0 extent: aRectangle extent).

	primaryLine ifNotNil: [
		primaryLine applyLayoutIn:
			(contentBounds origin extent: contentBounds width @ primaryLine measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	comment ifNotNil: [
		geometry := self commentGeometryFor: aRow contentWidth: contentBounds width.
		commentWidth := geometry first.
		commentY := geometry second.
		commentX := contentBounds left
			+ (aRow iconElement ifNil: [ 0 ] ifNotNil: [ aRow iconElement measuredWidth + aRow iconGap ])
			+ aRow commentLeftInset.
		comment applyLayoutIn:
			(commentX @ (contentBounds top + commentY) extent: commentWidth @ comment measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	self layoutIgnored: aRow context: aBlElementBoundsUpdateContext
]

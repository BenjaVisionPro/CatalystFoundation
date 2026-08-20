Class {
	#name : 'CFMaSettingsRowLayout',
	#superclass : 'BlLayout',
	#instVars : [
		'balancedColumns'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'constraints' }
CFMaSettingsRowLayout class >> constraints [
	^ BlLayoutCommonConstraints new
]

{ #category : 'initialization' }
CFMaSettingsRowLayout >> initialize [
	super initialize.
	balancedColumns := false
]

{ #category : 'private - measurement' }
CFMaSettingsRowLayout >> measureElement: anElement width: aWidth [
	| aParentSpec |
	anElement ifNil: [ ^ self ].
	aParentSpec := (BlMeasurementSpec exact: (aWidth max: 0))
		@ BlMeasurementSpec unspecified.
	self
		measureChild: anElement
		parentSpec: aParentSpec
]

{ #category : 'private - measurement' }
CFMaSettingsRowLayout >> naturalHeightOf: anElement [
	anElement ifNil: [ ^ 0 ].
	self
		measureChild: anElement
		parentSpec: BlMeasurementSpec unspecified @ BlMeasurementSpec unspecified.
	^ anElement measuredHeight
]

{ #category : 'private - measurement' }
CFMaSettingsRowLayout >> resetResponsiveWidthConstraintsFor: aRow [
	aRow labelElement ifNotNil: [ :anElement |
		anElement constraintsDo: [ :c | c maxWidth: Float infinity ] ].
	aRow editorElement ifNotNil: [ :anElement |
		anElement constraintsDo: [ :c | c maxWidth: Float infinity ] ]
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
CFMaSettingsRowLayout >> constrainBalancedColumnsFor: aRow contentWidth: aContentWidth [
	| columnWidth |
	columnWidth := self balancedColumnWidthFor: aRow contentWidth: aContentWidth.
	aRow labelElement ifNotNil: [ :anElement |
		anElement constraintsDo: [ :c | c maxWidth: columnWidth ] ].
	aRow editorElement ifNotNil: [ :anElement |
		anElement constraintsDo: [ :c | c maxWidth: columnWidth ] ]
]

{ #category : 'private - testing' }
CFMaSettingsRowLayout >> didElement: anElement growVerticallyFrom: aNaturalHeight [
	anElement ifNil: [ ^ false ].
	^ anElement measuredHeight > (aNaturalHeight + 0.5)
]

{ #category : 'private - geometry' }
CFMaSettingsRowLayout >> commentWidthFor: aRow contentWidth: aContentWidth [
	| iconWidth actionsWidth width |
	aRow commentElement ifNil: [ ^ 0 ].
	iconWidth := aRow iconElement
		ifNil: [ 0 ]
		ifNotNil: [ aRow iconElement measuredWidth + aRow iconGap ].
	actionsWidth := aRow actionsElement measuredWidth > 0
		ifTrue: [ aRow actionsElement measuredWidth + aRow actionsGap ]
		ifFalse: [ 0 ].
	width := balancedColumns
		ifTrue: [ self balancedColumnWidthFor: aRow contentWidth: aContentWidth ]
		ifFalse: [ aContentWidth - iconWidth - actionsWidth ].
	^ (width - aRow commentLeftInset) max: 0
]

{ #category : 'private - geometry' }
CFMaSettingsRowLayout >> commentYFor: aRow [
	^ (aRow labelElement
		ifNil: [ 0 ]
		ifNotNil: [ aRow labelElement measuredHeight ]) + aRow commentTopGap
]

{ #category : 'measure' }
CFMaSettingsRowLayout >> measure: aRow with: anExtentSpec [
	| primaryLine comment padding measuredWidth contentWidth naturalPrimaryHeight naturalCommentHeight commentWidth commentY contentHeight |
	primaryLine := aRow primaryLineElement.
	comment := aRow commentElement.
	padding := aRow padding.

	measuredWidth := anExtentSpec widthSpec sizeFor: padding width.
	contentWidth := (measuredWidth - padding width) max: 0.

	"Measure the row once without a width constraint to establish its stable,
	content-driven single-line heights. These values are independent of any
	previous constrained layout pass."
	self resetResponsiveWidthConstraintsFor: aRow.
	naturalPrimaryHeight := self naturalHeightOf: primaryLine.
	naturalCommentHeight := self naturalHeightOf: comment.

	"Now measure the normal presentation at the actual available width."
	balancedColumns := false.
	self measureElement: primaryLine width: contentWidth.
	commentWidth := self commentWidthFor: aRow contentWidth: contentWidth.
	self measureElement: comment width: commentWidth.

	"The balanced presentation is required when either semantic region actually
	reflows vertically. This is determined from measured geometry, not editor
	classes, cached spacer widths, or text implementation details."
	balancedColumns :=
		(self didElement: primaryLine growVerticallyFrom: naturalPrimaryHeight)
			or: [ self didElement: comment growVerticallyFrom: naturalCommentHeight ].

	balancedColumns ifTrue: [
		self constrainBalancedColumnsFor: aRow contentWidth: contentWidth.
		self measureElement: primaryLine width: contentWidth.
		commentWidth := self commentWidthFor: aRow contentWidth: contentWidth.
		self measureElement: comment width: commentWidth ].

	commentY := self commentYFor: aRow.
	contentHeight := primaryLine ifNil: [ 0 ] ifNotNil: [ primaryLine measuredHeight ].
	comment ifNotNil: [
		contentHeight := contentHeight max: (commentY + comment measuredHeight) ].

	aRow measuredExtent:
		(anExtentSpec sizeFor: measuredWidth @ (contentHeight + padding height))
]

{ #category : 'layout' }
CFMaSettingsRowLayout >> layout: aRow in: aRectangle context: aBlElementBoundsUpdateContext [
	| primaryLine comment padding contentBounds commentWidth commentY commentX |
	primaryLine := aRow primaryLineElement.
	comment := aRow commentElement.
	padding := aRow padding.
	contentBounds := padding inset: (0 @ 0 extent: aRectangle extent).

	primaryLine ifNotNil: [
		primaryLine applyLayoutIn:
			(contentBounds origin extent: contentBounds width @ primaryLine measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	comment ifNotNil: [
		commentWidth := self commentWidthFor: aRow contentWidth: contentBounds width.
		commentY := self commentYFor: aRow.
		commentX := contentBounds left
			+ (aRow iconElement ifNil: [ 0 ] ifNotNil: [ aRow iconElement measuredWidth + aRow iconGap ])
			+ aRow commentLeftInset.
		comment applyLayoutIn:
			(commentX @ (contentBounds top + commentY) extent: commentWidth @ comment measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	self layoutIgnored: aRow context: aBlElementBoundsUpdateContext
]

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
CFMaSettingsRowLayout >> commentGeometryFor: aRow contentWidth: aContentWidth [
	| editor comment iconWidth actionsWidth descriptionWidth commentWidth commentY hasFreeHorizontalSpace |
	editor := aRow editorElement.
	comment := aRow commentElement.
	comment ifNil: [ ^ { 0. 0. 0 } ].

	iconWidth := aRow iconElement
		ifNil: [ 0 ]
		ifNotNil: [ aRow iconElement measuredWidth + aRow iconGap ].
	actionsWidth := aRow actionsElement measuredWidth > 0
		ifTrue: [ aRow actionsElement measuredWidth + aRow actionsGap ]
		ifFalse: [ 0 ].

	"The linear layout's flexible spacer is the authoritative indication that
	the primary-line contents fit at their preferred widths. While it retains
	space, the comment can continue beneath the editor. Once it collapses, the
	limited label/editor regions are sharing constrained width and the comment
	stays in the description region beside the editor."
	hasFreeHorizontalSpace := aRow flexibleSpaceElement
		ifNil: [ false ]
		ifNotNil: [ aRow flexibleSpaceElement measuredWidth > 0 ].

	descriptionWidth := (aContentWidth
		- iconWidth
		- actionsWidth
		- (editor ifNil: [ 0 ] ifNotNil: [ editor measuredWidth ])
		- (editor ifNil: [ 0 ] ifNotNil: [ aRow fieldGap ])) max: 0.

	commentWidth := hasFreeHorizontalSpace
		ifTrue: [ aContentWidth - iconWidth - actionsWidth ]
		ifFalse: [ descriptionWidth ].

	commentWidth := (commentWidth - aRow commentLeftInset) max: 0.
	commentY := (aRow labelElement
		ifNil: [ 0 ]
		ifNotNil: [ aRow labelElement measuredHeight ]) + aRow commentTopGap.
	^ { commentWidth. commentY. descriptionWidth }
]

{ #category : 'measure' }
CFMaSettingsRowLayout >> measure: aRow with: anExtentSpec [
	| primaryLine comment padding measuredWidth contentWidth geometry commentWidth commentY contentHeight |
	primaryLine := aRow primaryLineElement.
	comment := aRow commentElement.
	padding := aRow padding.

	measuredWidth := anExtentSpec widthSpec sizeFor: padding width.
	contentWidth := (measuredWidth - padding width) max: 0.
	self measurePrimaryLine: primaryLine with: anExtentSpec width: contentWidth.

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

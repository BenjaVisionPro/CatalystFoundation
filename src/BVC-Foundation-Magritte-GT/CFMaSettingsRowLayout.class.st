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
	| label editor comment labelWidth editorHeight labelHeight descriptionWidth commentWidth commentY |
	label := aRow labelElement.
	editor := aRow editorElement.
	comment := aRow commentElement.
	comment ifNil: [ ^ { 0. 0. 0 } ].

	labelWidth := label ifNil: [ 0 ] ifNotNil: [ label measuredWidth ].
	editorHeight := editor ifNil: [ 0 ] ifNotNil: [ editor measuredHeight ].
	labelHeight := label ifNil: [ 0 ] ifNotNil: [ label measuredHeight ].
	descriptionWidth := labelWidth.

	"When the editor remains on the primary text line, the comment may use the
	remaining row width beneath it. Once the editor grows downward, the comment
	stays in the description column so both can grow vertically without overlap."
	(editor notNil and: [ label notNil and: [ editorHeight > labelHeight ] ])
		ifTrue: [ commentWidth := descriptionWidth ]
		ifFalse: [
			commentWidth := aContentWidth
				- (aRow iconElement ifNil: [ 0 ] ifNotNil: [ aRow iconElement measuredWidth + aRow iconGap ])
				- (aRow actionsElement measuredWidth > 0
					ifTrue: [ aRow actionsElement measuredWidth + aRow actionsGap ]
					ifFalse: [ 0 ]) ].
	commentWidth := (commentWidth - aRow commentLeftInset) max: 0.
	commentY := labelHeight + aRow commentTopGap.
	^ { commentWidth. commentY. descriptionWidth }
]

{ #category : 'measure' }
CFMaSettingsRowLayout >> measure: aRow with: anExtentSpec [
	| primaryLine comment padding measuredWidth contentWidth geometry commentWidth commentY contentHeight |
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

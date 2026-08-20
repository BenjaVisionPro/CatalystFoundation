Class {
	#name : 'CFMaSettingsRowLayout',
	#superclass : 'BlLayout',
	#instVars : [
		'descriptionWidth',
		'editorRegionWidth',
		'primaryHeight',
		'commentWidth',
		'commentSpansFlexibleWidth',
		'editorFillsRegion'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'constraints' }
CFMaSettingsRowLayout class >> constraints [
	^ BlLayoutCommonConstraints new
]

{ #category : 'private - measurement' }
CFMaSettingsRowLayout >> measureNaturally: anElement [
	anElement ifNil: [ ^ 0 @ 0 ].
	self
		measureChild: anElement
		parentSpec: BlExtentMeasurementSpec unspecified.
	^ anElement measuredExtent
]

{ #category : 'private - measurement' }
CFMaSettingsRowLayout >> measure: anElement withinWidth: aWidth [
	| aParentSpec |
	anElement ifNil: [ ^ 0 @ 0 ].
	aParentSpec := (BlMeasurementSpec exact: (aWidth max: 0))
		@ BlMeasurementSpec unspecified.
	self
		measureChild: anElement
		parentSpec: aParentSpec.
	^ anElement measuredExtent
]

{ #category : 'private - editor' }
CFMaSettingsRowLayout >> paragraphsIn: anEditor [
	anEditor ifNil: [ ^ #() ].
	^ anEditor allChildrenBreadthFirstSelect: [ :each |
		each isKindOf: CFMaSettingsRightAlignedParagraphElement ]
]


{ #category : 'private - editor' }
CFMaSettingsRowLayout >> preferredEditorWidthFor: anEditor [
	| paragraphs |
	anEditor ifNil: [ ^ 0 ].
	paragraphs := self paragraphsIn: anEditor.
	paragraphs isEmpty ifTrue: [
		^ (self measureNaturally: anEditor) x ].
	^ paragraphs first unwrappedWidth + anEditor padding width
]

{ #category : 'private - editor' }
CFMaSettingsRowLayout >> editorHasExplicitMultipleParagraphs: anEditor [
	| paragraphs |
	anEditor ifNil: [ ^ false ].
	paragraphs := self paragraphsIn: anEditor.
	^ paragraphs size > 1
]

{ #category : 'private - editor' }
CFMaSettingsRowLayout >> editorFillsRegion: anEditor in: aRow [
	anEditor ifNil: [ ^ false ].
	aRow hasDescription ifFalse: [ ^ true ].
	^ (self paragraphsIn: anEditor) notEmpty
]

{ #category : 'measure' }
CFMaSettingsRowLayout >> measure: aRow with: anExtentSpec [
	| icon label comment editor actions padding naturalIcon naturalActions preferredLabelWidth preferredEditorWidth preferredContentWidth measuredWidth contentWidth fixedWidth flexibleWidth fieldGap actionsGap preferredLineFits availableForColumns columnWidth labelHeight iconHeight actionsHeight editorHeight commentHeight commentY contentHeight descriptionHeight editorY |
	icon := aRow iconElement.
	label := aRow labelElement.
	comment := aRow commentElement.
	editor := aRow editorElement.
	actions := aRow actionsElement.
	padding := aRow padding.

	naturalIcon := self measureNaturally: icon.
	naturalActions := self measureNaturally: actions.
	preferredLabelWidth := (self measureNaturally: label) x.
	preferredEditorWidth := self preferredEditorWidthFor: editor.

	fieldGap := ((label notNil or: [ comment notNil ]) and: [ editor notNil ])
		ifTrue: [ aRow fieldGap ]
		ifFalse: [ 0 ].
	actionsGap := (actions notNil and: [ naturalActions x > 0 and: [ editor notNil ] ])
		ifTrue: [ aRow actionsGap ]
		ifFalse: [ 0 ].
	fixedWidth := naturalIcon x
		+ (icon ifNil: [ 0 ] ifNotNil: [ aRow iconGap ])
		+ naturalActions x
		+ actionsGap.
	preferredContentWidth := fixedWidth + preferredLabelWidth + fieldGap + preferredEditorWidth.
	measuredWidth := anExtentSpec widthSpec sizeFor: preferredContentWidth + padding width.
	contentWidth := (measuredWidth - padding width) max: 0.
	flexibleWidth := (contentWidth - fixedWidth) max: 0.

	editorFillsRegion := self editorFillsRegion: editor in: aRow.
	preferredLineFits := (self editorHasExplicitMultipleParagraphs: editor) not and: [
		preferredLabelWidth + fieldGap + preferredEditorWidth <= flexibleWidth ].

	editor ifNil: [
		descriptionWidth := flexibleWidth.
		editorRegionWidth := 0 ] ifNotNil: [
		(label isNil and: [ comment isNil ])
			ifTrue: [
				descriptionWidth := 0.
				editorRegionWidth := flexibleWidth ]
			ifFalse: [
				preferredLineFits
					ifTrue: [
						editorRegionWidth := editorFillsRegion
							ifTrue: [ (flexibleWidth - preferredLabelWidth - fieldGap) max: 0 ]
							ifFalse: [ preferredEditorWidth min: ((flexibleWidth - fieldGap) max: 0) ].
						descriptionWidth := (flexibleWidth - fieldGap - editorRegionWidth) max: 0 ]
					ifFalse: [
						availableForColumns := (flexibleWidth - fieldGap) max: 0.
						columnWidth := availableForColumns / 2.
						descriptionWidth := columnWidth.
						editorRegionWidth := columnWidth ] ] ].

	self measure: label withinWidth: descriptionWidth.
	self measure: editor withinWidth: editorRegionWidth.

	commentSpansFlexibleWidth := comment notNil
		and: [ editorFillsRegion and: [ preferredLineFits ] ].
	commentWidth := comment ifNil: [ 0 ] ifNotNil: [
		((commentSpansFlexibleWidth
			ifTrue: [ flexibleWidth ]
			ifFalse: [ descriptionWidth ]) - aRow commentLeftInset) max: 0 ].
	self measure: comment withinWidth: commentWidth.

	iconHeight := icon ifNil: [ 0 ] ifNotNil: [ icon measuredHeight ].
	actionsHeight := actions ifNil: [ 0 ] ifNotNil: [ actions measuredHeight ].
	labelHeight := label ifNil: [ 0 ] ifNotNil: [ label measuredHeight ].
	editorHeight := editor ifNil: [ 0 ] ifNotNil: [ editor measuredHeight ].
	primaryHeight := iconHeight max: actionsHeight.
	primaryHeight := primaryHeight max: labelHeight.
	primaryHeight isZero ifTrue: [ primaryHeight := editorHeight ].

	editorY := label
		ifNil: [ 0 ]
		ifNotNil: [ ((primaryHeight - labelHeight) / 2) max: 0 ].
	commentHeight := comment ifNil: [ 0 ] ifNotNil: [ comment measuredHeight ].
	commentY := comment ifNil: [ 0 ] ifNotNil: [
		commentSpansFlexibleWidth
			ifTrue: [ (primaryHeight max: (editorY + editorHeight)) + aRow commentTopGap ]
			ifFalse: [ (((primaryHeight - labelHeight) / 2) max: 0) + labelHeight + aRow commentTopGap ] ].
	descriptionHeight := comment ifNil: [ primaryHeight ] ifNotNil: [ commentY + commentHeight ].
	contentHeight := primaryHeight max: (editorY + editorHeight).
	contentHeight := contentHeight max: descriptionHeight.

	aRow measuredExtent:
		(anExtentSpec sizeFor: measuredWidth @ (contentHeight + padding height))
]

{ #category : 'layout' }
CFMaSettingsRowLayout >> layout: aRow in: aRectangle context: aBlElementBoundsUpdateContext [
	| icon label comment editor actions contentBounds flexibleLeft flexibleRight actionsX editorRegionLeft editorRegionRight labelY editorY actionsY iconY commentY labelHeight editorHeight actionsHeight iconHeight fieldGap actionsGap |
	icon := aRow iconElement.
	label := aRow labelElement.
	comment := aRow commentElement.
	editor := aRow editorElement.
	actions := aRow actionsElement.
	contentBounds := aRow padding inset: (0 @ 0 extent: aRectangle extent).
	flexibleLeft := contentBounds left.
	flexibleRight := contentBounds right.

	icon ifNotNil: [
		flexibleLeft := flexibleLeft + icon measuredWidth + aRow iconGap ].
	actionsGap := (actions notNil and: [ actions measuredWidth > 0 and: [ editor notNil ] ])
		ifTrue: [ aRow actionsGap ]
		ifFalse: [ 0 ].
	actionsX := contentBounds right - (actions ifNil: [ 0 ] ifNotNil: [ actions measuredWidth ]).
	actions ifNotNil: [ flexibleRight := actionsX - actionsGap ].
	fieldGap := ((label notNil or: [ comment notNil ]) and: [ editor notNil ])
		ifTrue: [ aRow fieldGap ]
		ifFalse: [ 0 ].
	editorRegionLeft := flexibleLeft + descriptionWidth + fieldGap.
	editorRegionRight := flexibleRight.

	labelHeight := label ifNil: [ 0 ] ifNotNil: [ label measuredHeight ].
	editorHeight := editor ifNil: [ 0 ] ifNotNil: [ editor measuredHeight ].
	actionsHeight := actions ifNil: [ 0 ] ifNotNil: [ actions measuredHeight ].
	iconHeight := icon ifNil: [ 0 ] ifNotNil: [ icon measuredHeight ].
	labelY := contentBounds top + (((primaryHeight - labelHeight) / 2) max: 0).
	editorY := contentBounds top + (label
		ifNil: [ 0 ]
		ifNotNil: [ ((primaryHeight - labelHeight) / 2) max: 0 ]).
	actionsY := contentBounds top + (((primaryHeight - actionsHeight) / 2) max: 0).
	iconY := contentBounds top + (((primaryHeight - iconHeight) / 2) max: 0).
	commentY := comment ifNil: [ contentBounds top ] ifNotNil: [
		commentSpansFlexibleWidth
			ifTrue: [ contentBounds top + (primaryHeight max: ((editorY - contentBounds top) + editorHeight)) + aRow commentTopGap ]
			ifFalse: [ labelY + labelHeight + aRow commentTopGap ] ].

	icon ifNotNil: [
		icon applyLayoutIn:
			(contentBounds left @ iconY extent: icon measuredExtent)
			context: aBlElementBoundsUpdateContext ].
	label ifNotNil: [
		label applyLayoutIn:
			(flexibleLeft @ labelY extent: label measuredExtent)
			context: aBlElementBoundsUpdateContext ].
	comment ifNotNil: [
		comment applyLayoutIn:
			((flexibleLeft + aRow commentLeftInset) @ commentY extent: comment measuredExtent)
			context: aBlElementBoundsUpdateContext ].
	editor ifNotNil: [
		| editorX |
		editorX := editorFillsRegion
			ifTrue: [ editorRegionLeft ]
			ifFalse: [ editorRegionRight - editor measuredWidth ].
		editor applyLayoutIn:
			(editorX @ editorY extent: editor measuredExtent)
			context: aBlElementBoundsUpdateContext ].
	actions ifNotNil: [
		actions applyLayoutIn:
			(actionsX @ actionsY extent: actions measuredExtent)
			context: aBlElementBoundsUpdateContext ].

	self layoutIgnored: aRow context: aBlElementBoundsUpdateContext
]

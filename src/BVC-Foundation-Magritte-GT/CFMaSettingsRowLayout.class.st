Class {
	#name : 'CFMaSettingsRowLayout',
	#superclass : 'BlLayout',
	#instVars : [
		'labelsWidth',
		'editorWidth',
		'primaryHeight'
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
	anElement measure: BlExtentMeasurementSpec unspecified.
	^ anElement measuredExtent
]

{ #category : 'private - measurement' }
CFMaSettingsRowLayout >> measure: anElement withinWidth: aWidth [
	anElement ifNil: [ ^ 0 @ 0 ].
	anElement measure: ((BlMeasurementSpec atMost: (aWidth max: 0)) @ BlMeasurementSpec unspecified).
	^ anElement measuredExtent
]

{ #category : 'private - measurement' }
CFMaSettingsRowLayout >> measureLabels: anElement atWidth: aWidth [
	anElement ifNil: [ ^ 0 @ 0 ].
	anElement measure: ((BlMeasurementSpec exact: (aWidth max: 0)) @ BlMeasurementSpec unspecified).
	^ anElement measuredExtent
]

{ #category : 'measure' }
CFMaSettingsRowLayout >> measure: aRow with: anExtentSpec [
	| icon labels editor actions padding naturalIcon naturalLabels naturalEditor naturalActions preferredContentWidth measuredWidth contentWidth fixedWidth flexibleWidth fieldGap contentHeight labelHeight iconHeight actionsHeight editorHeight labelsHeight hasLabels |
	icon := aRow iconElement.
	labels := aRow labelsElement.
	editor := aRow editorElement.
	actions := aRow actionsElement.
	padding := aRow padding.

	naturalIcon := self measureNaturally: icon.
	naturalLabels := self measureNaturally: labels.
	naturalEditor := self measureNaturally: editor.
	naturalActions := self measureNaturally: actions.

	hasLabels := aRow hasLabels.
	fieldGap := (hasLabels and: [ editor notNil ])
		ifTrue: [ aRow fieldGap ]
		ifFalse: [ 0 ].
	fixedWidth := naturalIcon x
		+ (icon ifNil: [ 0 ] ifNotNil: [ aRow iconGap ])
		+ naturalActions x
		+ ((actions notNil and: [ naturalActions x > 0 and: [ editor notNil ] ])
			ifTrue: [ aRow actionsGap ]
			ifFalse: [ 0 ]).
	preferredContentWidth := fixedWidth + naturalLabels x + fieldGap + naturalEditor x.
	measuredWidth := anExtentSpec widthSpec sizeFor: preferredContentWidth + padding width.
	contentWidth := (measuredWidth - padding width) max: 0.
	flexibleWidth := (contentWidth - fixedWidth) max: 0.

	hasLabels
		ifFalse: [
			labelsWidth := 0.
			editorWidth := flexibleWidth ]
		ifTrue: [
			editor ifNil: [
				labelsWidth := flexibleWidth.
				editorWidth := 0 ] ifNotNil: [
				(naturalLabels x + fieldGap + naturalEditor x <= flexibleWidth)
					ifTrue: [
						editorWidth := naturalEditor x min: (flexibleWidth - fieldGap max: 0).
						labelsWidth := (flexibleWidth - fieldGap - editorWidth) max: 0 ]
					ifFalse: [
						labelsWidth := ((flexibleWidth - fieldGap) / 2) max: 0.
						editorWidth := labelsWidth ] ] ].

	self measureLabels: labels atWidth: labelsWidth.
	self measure: editor withinWidth: editorWidth.

	iconHeight := icon ifNil: [ 0 ] ifNotNil: [ icon measuredHeight ].
	actionsHeight := actions ifNil: [ 0 ] ifNotNil: [ actions measuredHeight ].
	editorHeight := editor ifNil: [ 0 ] ifNotNil: [ editor measuredHeight ].
	labelsHeight := labels ifNil: [ 0 ] ifNotNil: [ labels measuredHeight ].
	labelHeight := aRow labelElement ifNil: [ 0 ] ifNotNil: [ aRow labelElement measuredHeight ].
	primaryHeight := iconHeight max: actionsHeight.
	primaryHeight := primaryHeight max: labelHeight.
	(primaryHeight isZero or: [ editorHeight <= (labelHeight max: primaryHeight) * 1.5 ])
		ifTrue: [ primaryHeight := primaryHeight max: editorHeight ].
	contentHeight := primaryHeight max: labelsHeight.
	contentHeight := contentHeight max: editorHeight.

	aRow
		measuredExtent: (anExtentSpec sizeFor: measuredWidth @ (contentHeight + padding height))
]

{ #category : 'layout' }
CFMaSettingsRowLayout >> layout: aRow in: aRectangle context: aBlElementBoundsUpdateContext [
	| icon labels editor actions contentBounds x right labelHeight iconHeight labelsHeight editorHeight actionsHeight labelsY editorY actionsY iconY fieldGap actionsGap editorAreaRight hasLabels |
	icon := aRow iconElement.
	labels := aRow labelsElement.
	editor := aRow editorElement.
	actions := aRow actionsElement.
	contentBounds := aRow padding inset: (0 @ 0 extent: aRectangle extent).
	x := contentBounds left.
	right := contentBounds right.

	icon ifNotNil: [
		x := x + icon measuredWidth + aRow iconGap ].
	actionsGap := (actions notNil and: [ actions measuredWidth > 0 and: [ editor notNil ] ])
		ifTrue: [ aRow actionsGap ]
		ifFalse: [ 0 ].
	actions ifNotNil: [ right := right - actions measuredWidth - actionsGap ].

	hasLabels := aRow hasLabels.
	fieldGap := (hasLabels and: [ editor notNil ])
		ifTrue: [ aRow fieldGap ]
		ifFalse: [ 0 ].
	editorAreaRight := right.

	labelHeight := aRow labelElement ifNil: [ 0 ] ifNotNil: [ aRow labelElement measuredHeight ].
	iconHeight := icon ifNil: [ 0 ] ifNotNil: [ icon measuredHeight ].
	labelsHeight := labels ifNil: [ 0 ] ifNotNil: [ labels measuredHeight ].
	editorHeight := editor ifNil: [ 0 ] ifNotNil: [ editor measuredHeight ].
	actionsHeight := actions ifNil: [ 0 ] ifNotNil: [ actions measuredHeight ].
	primaryHeight := iconHeight max: actionsHeight.
	primaryHeight := primaryHeight max: labelHeight.
	(primaryHeight isZero or: [ editorHeight <= (labelHeight max: primaryHeight) * 1.5 ])
		ifTrue: [ primaryHeight := primaryHeight max: editorHeight ].

	labelsY := contentBounds top + ((primaryHeight - labelHeight) / 2 max: 0).
	editorY := editorHeight <= primaryHeight
		ifTrue: [ contentBounds top + ((primaryHeight - editorHeight) / 2 max: 0) ]
		ifFalse: [ contentBounds top ].
	actionsY := contentBounds top + ((primaryHeight - actionsHeight) / 2 max: 0).
	iconY := (labelsHeight > primaryHeight or: [ editorHeight > primaryHeight ])
		ifTrue: [ contentBounds top ]
		ifFalse: [ contentBounds top + ((primaryHeight - iconHeight) / 2 max: 0) ].

	icon ifNotNil: [
		icon applyLayoutIn: (contentBounds left @ iconY extent: icon measuredExtent) context: aBlElementBoundsUpdateContext ].
	labels ifNotNil: [
		labels applyLayoutIn: (x @ labelsY extent: labels measuredExtent) context: aBlElementBoundsUpdateContext ].
	editor ifNotNil: [
		editor applyLayoutIn: ((editorAreaRight - editor measuredWidth) @ editorY extent: editor measuredExtent) context: aBlElementBoundsUpdateContext ].
	actions ifNotNil: [
		actions applyLayoutIn: ((contentBounds right - actions measuredWidth) @ actionsY extent: actions measuredExtent) context: aBlElementBoundsUpdateContext ].

	self layoutIgnored: aRow context: aBlElementBoundsUpdateContext
]

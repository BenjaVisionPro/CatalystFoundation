Class {
	#name : 'CFMaDetailPopupLayout',
	#superclass : 'BlLayout',
	#category : 'BVC-Foundation-Magritte-Detail-Layout',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Layout'
}




{ #category : 'measure' }
CFMaDetailPopupLayout >> measure: anElement with: anExtentSpec [
	| children padding leading label indicator desiredWidth desiredHeight contentWidth contentHeight |
	children := anElement children accountedByLayout.
	leading := children size = 3 ifTrue: [ children first ] ifFalse: [ nil ].
	label := children size = 3
		ifTrue: [ children second ]
		ifFalse: [ children ifNotEmpty: [ children first ] ifEmpty: [ nil ] ].
	indicator := children size = 3
		ifTrue: [ children third ]
		ifFalse: [ children size > 1 ifTrue: [ children second ] ifFalse: [ nil ] ].

	{ leading. label. indicator } do: [ :each |
		each ifNotNil: [
			self measureChild: each parentSpec: BlExtentMeasurementSpec unspecified ] ].

	padding := anElement padding.
	contentWidth := (leading ifNil: [ 0.0 ] ifNotNil: [ leading measuredWidth + leading margin width ])
		+ (label ifNil: [ 0.0 ] ifNotNil: [ label measuredWidth ])
		+ ((label notNil and: [ indicator notNil ])
			ifTrue: [ CFMaDetailPopupMetrics labelIndicatorGap ]
			ifFalse: [ 0.0 ])
		+ (indicator ifNil: [ 0.0 ] ifNotNil: [ indicator measuredWidth ]).
	contentHeight := {
		leading ifNil: [ 0.0 ] ifNotNil: [ leading measuredHeight ].
		label ifNil: [ 0.0 ] ifNotNil: [ label measuredHeight ].
		indicator ifNil: [ 0.0 ] ifNotNil: [ indicator measuredHeight ] } max.
	desiredWidth := padding width + contentWidth.
	desiredHeight := padding height + contentHeight.

	anElement measuredExtent: (anExtentSpec sizeFor: desiredWidth @ desiredHeight).
	self measureIgnored: anElement with: (BlExtentMeasurementSpec exact: anElement measuredExtent)
]

{ #category : 'layout' }
CFMaDetailPopupLayout >> layout: anElement in: aRectangle context: aBlElementBoundsUpdateContext [
	| children padding leading label indicator x innerHeight y |
	children := anElement children accountedByLayout.
	leading := children size = 3 ifTrue: [ children first ] ifFalse: [ nil ].
	label := children size = 3
		ifTrue: [ children second ]
		ifFalse: [ children ifNotEmpty: [ children first ] ifEmpty: [ nil ] ].
	indicator := children size = 3
		ifTrue: [ children third ]
		ifFalse: [ children size > 1 ifTrue: [ children second ] ifFalse: [ nil ] ].
	padding := anElement padding.
	x := padding left.
	innerHeight := (aRectangle height - padding height) max: 0.0.

	leading ifNotNil: [
		y := padding top + ((innerHeight - leading measuredHeight) / 2.0).
		leading
			applyLayoutIn: ((x + leading margin left) @ y extent: leading measuredExtent)
			context: aBlElementBoundsUpdateContext.
		x := x + leading measuredWidth + leading margin width ].

	label ifNotNil: [
		y := padding top + ((innerHeight - label measuredHeight) / 2.0).
		label
			applyLayoutIn: (x @ y extent: label measuredExtent)
			context: aBlElementBoundsUpdateContext.
		x := x + label measuredWidth ].

	(label notNil and: [ indicator notNil ]) ifTrue: [
		x := x + CFMaDetailPopupMetrics labelIndicatorGap ].
	indicator ifNotNil: [
		y := padding top + ((innerHeight - indicator measuredHeight) / 2.0).
		indicator
			applyLayoutIn: (x @ y extent: indicator measuredExtent)
			context: aBlElementBoundsUpdateContext ].

	self layoutIgnored: anElement context: aBlElementBoundsUpdateContext
]

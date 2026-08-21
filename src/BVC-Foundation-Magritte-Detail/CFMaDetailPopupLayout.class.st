Class {
	#name : 'CFMaDetailPopupLayout',
	#superclass : 'BlLayout',
	#category : 'BVC-Foundation-Magritte-Detail-Layout',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Layout'
}




{ #category : 'measure' }
CFMaDetailPopupLayout >> measure: anElement with: anExtentSpec [
	| children padding label indicator desiredWidth desiredHeight |
	children := anElement children accountedByLayout.
	label := children ifNotEmpty: [ children first ] ifEmpty: [ nil ].
	indicator := children size > 1 ifTrue: [ children second ] ifFalse: [ nil ].

	label ifNotNil: [
		self measureChild: label parentSpec: BlExtentMeasurementSpec unspecified ].
	indicator ifNotNil: [
		self measureChild: indicator parentSpec: BlExtentMeasurementSpec unspecified ].

	padding := anElement padding.
	desiredWidth := padding width
		+ (label ifNil: [ 0.0 ] ifNotNil: [ label measuredWidth ])
		+ ((label notNil and: [ indicator notNil ]) ifTrue: [ CFMaDetailPopupMetrics labelIndicatorGap ] ifFalse: [ 0.0 ])
		+ (indicator ifNil: [ 0.0 ] ifNotNil: [ indicator measuredWidth ]).
	desiredHeight := padding height + ((label ifNil: [ 0.0 ] ifNotNil: [ label measuredHeight ])
		max: (indicator ifNil: [ 0.0 ] ifNotNil: [ indicator measuredHeight ])).

	anElement measuredExtent: (anExtentSpec sizeFor: desiredWidth @ desiredHeight).
	self measureIgnored: anElement with: (BlExtentMeasurementSpec exact: anElement measuredExtent)
]

{ #category : 'layout' }
CFMaDetailPopupLayout >> layout: anElement in: aRectangle context: aBlElementBoundsUpdateContext [
	| children padding label indicator x innerHeight labelY indicatorY |
	children := anElement children accountedByLayout.
	label := children ifNotEmpty: [ children first ] ifEmpty: [ nil ].
	indicator := children size > 1 ifTrue: [ children second ] ifFalse: [ nil ].
	padding := anElement padding.
	x := padding left.
	innerHeight := (aRectangle height - padding height) max: 0.0.

	label ifNotNil: [
		labelY := padding top + ((innerHeight - label measuredHeight) / 2.0).
		label
			applyLayoutIn: (x @ labelY extent: label measuredExtent)
			context: aBlElementBoundsUpdateContext.
		x := x + label measuredWidth ].

	(label notNil and: [ indicator notNil ]) ifTrue: [ x := x + CFMaDetailPopupMetrics labelIndicatorGap ].
	indicator ifNotNil: [
		indicatorY := padding top + ((innerHeight - indicator measuredHeight) / 2.0).
		indicator
			applyLayoutIn: (x @ indicatorY extent: indicator measuredExtent)
			context: aBlElementBoundsUpdateContext ].

	self layoutIgnored: anElement context: aBlElementBoundsUpdateContext
]

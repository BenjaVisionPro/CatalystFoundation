Class {
	#name : 'CFMaDetailSliderLayout',
	#superclass : 'BlLayout',
	#category : 'BVC-Foundation-Magritte-Detail-Layout',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Layout'
}

{ #category : 'measure' }
CFMaDetailSliderLayout >> measure: anElement with: anExtentSpec [
	| children minLabel currentLabel maxLabel desiredWidth desiredHeight |
	children := anElement children accountedByLayout.
	minLabel := children fourth.
	currentLabel := children fifth.
	maxLabel := children sixth.
	{ minLabel. currentLabel. maxLabel } do: [ :aLabel |
		self measureChild: aLabel parentSpec: BlExtentMeasurementSpec unspecified ].
	desiredWidth := anExtentSpec widthSpec isUnspecified
		ifTrue: [ 180.0 ]
		ifFalse: [ anExtentSpec widthSpec size ].
	desiredHeight := 20.0 + ((minLabel measuredHeight max: currentLabel measuredHeight) max: maxLabel measuredHeight).
	anElement measuredExtent: (anExtentSpec sizeFor: desiredWidth @ desiredHeight).
	self measureIgnored: anElement with: (BlExtentMeasurementSpec exact: anElement measuredExtent)
]

{ #category : 'layout' }
CFMaDetailSliderLayout >> layout: anElement in: aRectangle context: aBlElementBoundsUpdateContext [
	| children track fill thumb minLabel currentLabel maxLabel fraction trackY trackHeight thumbExtent thumbCenterX labelY currentX |
	children := anElement children accountedByLayout.
	track := children first.
	fill := children second.
	thumb := children third.
	minLabel := children fourth.
	currentLabel := children fifth.
	maxLabel := children sixth.
	fraction := anElement normalizedValue.
	trackY := 6.0.
	trackHeight := 4.0.
	thumbExtent := 12.0 @ 12.0.
	thumbCenterX := fraction * aRectangle width.
	track applyLayoutIn: (0.0 @ trackY extent: aRectangle width @ trackHeight) context: aBlElementBoundsUpdateContext.
	fill applyLayoutIn: (0.0 @ trackY extent: thumbCenterX @ trackHeight) context: aBlElementBoundsUpdateContext.
	thumb applyLayoutIn: ((thumbCenterX - (thumbExtent x / 2.0)) @ (trackY - 4.0) extent: thumbExtent) context: aBlElementBoundsUpdateContext.
	labelY := 20.0.
	minLabel applyLayoutIn: (0.0 @ labelY extent: minLabel measuredExtent) context: aBlElementBoundsUpdateContext.
	maxLabel applyLayoutIn: ((aRectangle width - maxLabel measuredWidth) @ labelY extent: maxLabel measuredExtent) context: aBlElementBoundsUpdateContext.
	currentX := (thumbCenterX - (currentLabel measuredWidth / 2.0))
		max: minLabel measuredWidth + 6.0.
	currentX := currentX min: aRectangle width - maxLabel measuredWidth - currentLabel measuredWidth - 6.0.
	currentLabel applyLayoutIn: (currentX @ labelY extent: currentLabel measuredExtent) context: aBlElementBoundsUpdateContext.
	self layoutIgnored: anElement context: aBlElementBoundsUpdateContext
]

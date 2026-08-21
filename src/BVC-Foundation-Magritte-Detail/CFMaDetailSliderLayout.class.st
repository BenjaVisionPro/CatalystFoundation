Class {
	#name : 'CFMaDetailSliderLayout',
	#superclass : 'BlLayout',
	#category : 'BVC-Foundation-Magritte-Detail-Layout',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Layout'
}

{ #category : 'measure' }
CFMaDetailSliderLayout >> measure: anElement with: anExtentSpec [
	| children minLabel currentLabel maxLabel desiredWidth desiredHeight labelHeight |
	children := anElement children accountedByLayout.
	minLabel := children at: 7.
	currentLabel := children at: 8.
	maxLabel := children at: 9.
	{ minLabel. currentLabel. maxLabel } do: [ :aLabel |
		self measureChild: aLabel parentSpec: BlExtentMeasurementSpec unspecified ].
	desiredWidth := anExtentSpec widthSpec isUnspecified
		ifTrue: [ 180.0 ]
		ifFalse: [ anExtentSpec widthSpec size ].
	labelHeight := (minLabel measuredHeight max: currentLabel measuredHeight) max: maxLabel measuredHeight.
	desiredHeight := CFMaDetailSliderMetrics contentHeightBeforeLabels + labelHeight.
	anElement measuredExtent: (anExtentSpec sizeFor: desiredWidth @ desiredHeight).
	self measureIgnored: anElement with: (BlExtentMeasurementSpec exact: anElement measuredExtent)
]

{ #category : 'layout' }
CFMaDetailSliderLayout >> layout: anElement in: aRectangle context: aBlElementBoundsUpdateContext [
	| children track fill thumb minTick middleTick maxTick minLabel currentLabel maxLabel fraction axisInset axisStart axisEnd axisWidth trackY trackHeight thumbExtent thumbCenterX tickExtent tickY labelY currentX |
	children := anElement children accountedByLayout.
	track := children at: 1.
	fill := children at: 2.
	thumb := children at: 3.
	minTick := children at: 4.
	middleTick := children at: 5.
	maxTick := children at: 6.
	minLabel := children at: 7.
	currentLabel := children at: 8.
	maxLabel := children at: 9.
	fraction := anElement normalizedValue.
	axisInset := CFMaDetailSliderMetrics axisInset.
	axisStart := axisInset.
	axisEnd := aRectangle width - axisInset.
	axisWidth := (axisEnd - axisStart) max: 0.0.
	trackY := CFMaDetailSliderMetrics trackY.
	trackHeight := CFMaDetailSliderMetrics trackHeight.
	thumbExtent := CFMaDetailSliderMetrics thumbExtent.
	thumbCenterX := axisStart + (fraction * axisWidth).
	track applyLayoutIn: (0.0 @ trackY extent: aRectangle width @ trackHeight) context: aBlElementBoundsUpdateContext.
	fill applyLayoutIn: (0.0 @ trackY extent: thumbCenterX @ trackHeight) context: aBlElementBoundsUpdateContext.
	thumb applyLayoutIn: ((thumbCenterX - (thumbExtent x / 2.0)) @ (trackY + (trackHeight / 2.0) - (thumbExtent y / 2.0)) extent: thumbExtent) context: aBlElementBoundsUpdateContext.
	tickExtent := CFMaDetailSliderMetrics tickExtent.
	tickY := CFMaDetailSliderMetrics tickY.
	minTick applyLayoutIn: ((axisStart - (tickExtent x / 2.0)) @ tickY extent: tickExtent) context: aBlElementBoundsUpdateContext.
	middleTick applyLayoutIn: (((axisStart + (axisWidth / 2.0)) - (tickExtent x / 2.0)) @ tickY extent: tickExtent) context: aBlElementBoundsUpdateContext.
	maxTick applyLayoutIn: ((axisEnd - (tickExtent x / 2.0)) @ tickY extent: tickExtent) context: aBlElementBoundsUpdateContext.
	labelY := CFMaDetailSliderMetrics labelY.
	minLabel applyLayoutIn: ((axisStart - (minLabel measuredWidth / 2.0)) @ labelY extent: minLabel measuredExtent) context: aBlElementBoundsUpdateContext.
	maxLabel applyLayoutIn: ((axisEnd - (maxLabel measuredWidth / 2.0)) @ labelY extent: maxLabel measuredExtent) context: aBlElementBoundsUpdateContext.
	currentX := (thumbCenterX - (currentLabel measuredWidth / 2.0))
		max: minLabel measuredWidth + 6.0.
	currentX := currentX min: aRectangle width - maxLabel measuredWidth - currentLabel measuredWidth - 6.0.
	currentLabel applyLayoutIn: (currentX @ labelY extent: currentLabel measuredExtent) context: aBlElementBoundsUpdateContext.
	self layoutIgnored: anElement context: aBlElementBoundsUpdateContext
]

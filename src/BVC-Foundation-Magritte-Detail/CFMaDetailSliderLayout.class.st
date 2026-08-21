Class {
	#name : 'CFMaDetailSliderLayout',
	#superclass : 'BlLayout',
	#category : 'BVC-Foundation-Magritte-Detail-Layout',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Layout'
}

{ #category : 'measure' }
CFMaDetailSliderLayout >> measure: anElement with: anExtentSpec [
	| minLabel currentLabel maxLabel desiredWidth desiredHeight labelHeight |
	minLabel := anElement minimumLabel.
	currentLabel := anElement currentLabel.
	maxLabel := anElement maximumLabel.
	{ minLabel. currentLabel. maxLabel } do: [ :aLabel |
		self measureChild: aLabel parentSpec: BlExtentMeasurementSpec unspecified ].
	desiredWidth := anExtentSpec widthSpec isUnspecified
		ifTrue: [ 180.0 ]
		ifFalse: [ anExtentSpec widthSpec size ].
	labelHeight := (minLabel measuredHeight max: currentLabel measuredHeight) max: maxLabel measuredHeight.
	desiredHeight := CFMaDetailSliderMetrics labelY + labelHeight.
	anElement measuredExtent: (anExtentSpec sizeFor: desiredWidth @ desiredHeight).
	self measureIgnored: anElement with: (BlExtentMeasurementSpec exact: anElement measuredExtent)
]

{ #category : 'layout' }
CFMaDetailSliderLayout >> layout: anElement in: aRectangle context: aBlElementBoundsUpdateContext [
	| track fill minTick middleTick maxTick thumb minLabel currentLabel maxLabel padding innerLeft innerRight innerWidth fraction axisInset axisStart axisEnd axisWidth trackY trackHeight trackInset trackWidth thumbExtent thumbCenterX tickExtent tickY labelY minX maxX currentX |
	track := anElement sliderTrack.
	fill := anElement sliderFill.
	minTick := anElement minimumTick.
	middleTick := anElement middleTick.
	maxTick := anElement maximumTick.
	thumb := anElement sliderThumb.
	minLabel := anElement minimumLabel.
	currentLabel := anElement currentLabel.
	maxLabel := anElement maximumLabel.
	padding := anElement padding.
	innerLeft := padding left.
	innerRight := aRectangle width - padding right.
	innerWidth := (innerRight - innerLeft) max: 0.0.
	fraction := anElement normalizedValue.
	axisInset := CFMaDetailSliderMetrics axisInset.
	axisStart := innerLeft + axisInset.
	axisEnd := innerRight - axisInset.
	axisWidth := (axisEnd - axisStart) max: 0.0.
	trackY := CFMaDetailSliderMetrics trackY.
	trackHeight := CFMaDetailSliderMetrics trackHeight.
	trackInset := CFMaDetailSliderMetrics trackEndOcclusion.
	trackWidth := (innerWidth - (trackInset * 2.0)) max: 0.0.
	thumbExtent := CFMaDetailSliderMetrics thumbExtent.
	thumbCenterX := axisStart + (fraction * axisWidth).
	track applyLayoutIn: ((innerLeft + trackInset) @ trackY extent: trackWidth @ trackHeight) context: aBlElementBoundsUpdateContext.
	fill applyLayoutIn: ((innerLeft + trackInset) @ trackY extent: ((thumbCenterX - innerLeft - trackInset) max: 0.0) @ trackHeight) context: aBlElementBoundsUpdateContext.
	thumb applyLayoutIn: ((thumbCenterX - (thumbExtent x / 2.0)) @ (trackY + (trackHeight / 2.0) - (thumbExtent y / 2.0)) extent: thumbExtent) context: aBlElementBoundsUpdateContext.
	tickExtent := CFMaDetailSliderMetrics tickExtent.
	tickY := CFMaDetailSliderMetrics tickY.
	minTick applyLayoutIn: ((axisStart - (tickExtent x / 2.0)) @ tickY extent: tickExtent) context: aBlElementBoundsUpdateContext.
	middleTick applyLayoutIn: (((axisStart + (axisWidth / 2.0)) - (tickExtent x / 2.0)) @ tickY extent: tickExtent) context: aBlElementBoundsUpdateContext.
	maxTick applyLayoutIn: ((axisEnd - (tickExtent x / 2.0)) @ tickY extent: tickExtent) context: aBlElementBoundsUpdateContext.
	labelY := CFMaDetailSliderMetrics labelY.
	minX := (axisStart - (minLabel measuredWidth / 2.0)) max: innerLeft.
	maxX := (axisEnd - (maxLabel measuredWidth / 2.0)) min: innerRight - maxLabel measuredWidth.
	minLabel applyLayoutIn: (minX @ labelY extent: minLabel measuredExtent) context: aBlElementBoundsUpdateContext.
	maxLabel applyLayoutIn: (maxX @ labelY extent: maxLabel measuredExtent) context: aBlElementBoundsUpdateContext.
	currentX := (thumbCenterX - (currentLabel measuredWidth / 2.0))
		max: minX + minLabel measuredWidth + 6.0.
	currentX := currentX min: maxX - currentLabel measuredWidth - 6.0.
	currentLabel applyLayoutIn: (currentX @ labelY extent: currentLabel measuredExtent) context: aBlElementBoundsUpdateContext.
	self layoutIgnored: anElement context: aBlElementBoundsUpdateContext
]

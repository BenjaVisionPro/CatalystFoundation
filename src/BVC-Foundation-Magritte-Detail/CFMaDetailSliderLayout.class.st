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
	minLabel := children at: 7.
	currentLabel := children at: 8.
	maxLabel := children at: 9.
	{ minLabel. currentLabel. maxLabel } do: [ :aLabel |
		self measureChild: aLabel parentSpec: BlExtentMeasurementSpec unspecified ].
	desiredWidth := anExtentSpec widthSpec isUnspecified
		ifTrue: [ 180.0 ]
		ifFalse: [ anExtentSpec widthSpec size ].
	desiredHeight := 28.0 + ((minLabel measuredHeight max: currentLabel measuredHeight) max: maxLabel measuredHeight).
	anElement measuredExtent: (anExtentSpec sizeFor: desiredWidth @ desiredHeight).
	self measureIgnored: anElement with: (BlExtentMeasurementSpec exact: anElement measuredExtent)
]

{ #category : 'layout' }
CFMaDetailSliderLayout >> layout: anElement in: aRectangle context: aBlElementBoundsUpdateContext [
	| children track fill thumb minTick middleTick maxTick minLabel currentLabel maxLabel fraction trackY trackHeight thumbExtent thumbCenterX tickExtent tickY labelY currentX |
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
	trackY := 8.0.
	trackHeight := 4.0.
	thumbExtent := 20.0 @ 20.0.
	thumbCenterX := fraction * aRectangle width.
	track applyLayoutIn: (0.0 @ trackY extent: aRectangle width @ trackHeight) context: aBlElementBoundsUpdateContext.
	fill applyLayoutIn: (0.0 @ trackY extent: thumbCenterX @ trackHeight) context: aBlElementBoundsUpdateContext.
	thumb applyLayoutIn: ((thumbCenterX - (thumbExtent x / 2.0)) @ (trackY + (trackHeight / 2.0) - (thumbExtent y / 2.0)) extent: thumbExtent) context: aBlElementBoundsUpdateContext.
	tickExtent := 2.5 @ 2.5.
	tickY := 20.0.
	minTick applyLayoutIn: (0.0 @ tickY extent: tickExtent) context: aBlElementBoundsUpdateContext.
	middleTick applyLayoutIn: (((aRectangle width - tickExtent x) / 2.0) @ tickY extent: tickExtent) context: aBlElementBoundsUpdateContext.
	maxTick applyLayoutIn: ((aRectangle width - tickExtent x) @ tickY extent: tickExtent) context: aBlElementBoundsUpdateContext.
	labelY := 25.0.
	minLabel applyLayoutIn: (0.0 @ labelY extent: minLabel measuredExtent) context: aBlElementBoundsUpdateContext.
	maxLabel applyLayoutIn: ((aRectangle width - maxLabel measuredWidth) @ labelY extent: maxLabel measuredExtent) context: aBlElementBoundsUpdateContext.
	currentX := (thumbCenterX - (currentLabel measuredWidth / 2.0))
		max: minLabel measuredWidth + 6.0.
	currentX := currentX min: aRectangle width - maxLabel measuredWidth - currentLabel measuredWidth - 6.0.
	currentLabel applyLayoutIn: (currentX @ labelY extent: currentLabel measuredExtent) context: aBlElementBoundsUpdateContext.
	self layoutIgnored: anElement context: aBlElementBoundsUpdateContext
]

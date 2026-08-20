Class {
	#name : 'CFMaSettingsRowLayout',
	#superclass : 'BlLayout',
	#instVars : [
		'wrapped',
		'iconWidth',
		'descriptionWidth',
		'editorWidth'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'constraints' }
CFMaSettingsRowLayout class >> constraints [
	^ BlLayoutCommonConstraints new
]

{ #category : 'measure' }
CFMaSettingsRowLayout >> measure: aRow with: anExtentSpec [
	| padding availableWidth icon iconHeight bodyWidth descriptionLine descriptionRegion editorRegion naturalDescriptionWidth naturalEditorWidth halfWidth descriptionHeight editorHeight contentHeight desiredWidth desiredHeight |
	padding := aRow padding.

	icon := aRow iconElement.
	iconWidth := 0.
	iconHeight := 0.
	icon ifNotNil: [
		self measureChild: icon parentSpec: BlExtentMeasurementSpec unspecified.
		iconWidth := icon measuredWidth + aRow iconGap.
		iconHeight := icon measuredHeight ].

	descriptionLine := aRow descriptionLineElement.
	descriptionRegion := aRow descriptionRegionElement.
	editorRegion := aRow editorRegionElement.

	naturalDescriptionWidth := 0.
	descriptionLine ifNotNil: [
		self measureChild: descriptionLine parentSpec: BlExtentMeasurementSpec unspecified.
		naturalDescriptionWidth := descriptionLine measuredWidth ].

	naturalEditorWidth := 0.
	editorRegion ifNotNil: [
		self measureChild: editorRegion parentSpec: BlExtentMeasurementSpec unspecified.
		naturalEditorWidth := editorRegion measuredWidth ].

	availableWidth := anExtentSpec widthSpec isUnspecified
		ifTrue: [ iconWidth + naturalDescriptionWidth + (editorRegion ifNil: [ 0 ] ifNotNil: [ aRow fieldGap + naturalEditorWidth ]) ]
		ifFalse: [ (anExtentSpec widthSpec size - padding width) max: 0 ].
	bodyWidth := (availableWidth - iconWidth) max: 0.
	halfWidth := ((bodyWidth - aRow fieldGap) max: 0) / 2.

	wrapped := editorRegion notNil and: [
		naturalEditorWidth > halfWidth
			or: [ naturalDescriptionWidth + aRow fieldGap + naturalEditorWidth > bodyWidth ] ].

	descriptionWidth := wrapped ifTrue: [ halfWidth ] ifFalse: [ bodyWidth ].
	editorWidth := editorRegion
		ifNil: [ 0 ]
		ifNotNil: [ wrapped
			ifTrue: [ halfWidth ]
			ifFalse: [ naturalEditorWidth min: bodyWidth ] ].

	descriptionHeight := 0.
	descriptionRegion ifNotNil: [
		self
			measureChild: descriptionRegion
			parentSpec: ((BlMeasurementSpec exact: descriptionWidth) @ BlMeasurementSpec unspecified).
		descriptionHeight := descriptionRegion measuredHeight ].

	editorHeight := 0.
	editorRegion ifNotNil: [
		self
			measureChild: editorRegion
			parentSpec: ((BlMeasurementSpec exact: editorWidth) @ BlMeasurementSpec unspecified).
		editorHeight := editorRegion measuredHeight ].

	contentHeight := iconHeight max: (descriptionHeight max: editorHeight).
	desiredWidth := availableWidth + padding width.
	desiredHeight := contentHeight + padding height.
	aRow measuredExtent: (anExtentSpec sizeFor: desiredWidth @ desiredHeight).

	self measureIgnored: aRow with: (BlExtentMeasurementSpec exact: aRow measuredExtent)
]

{ #category : 'layout' }
CFMaSettingsRowLayout >> layout: aRow in: aRectangle context: aBlElementBoundsUpdateContext [
	| padding x y icon bodyX bodyWidth descriptionRegion editorRegion editorX |
	padding := aRow padding.
	x := padding left.
	y := padding top.

	icon := aRow iconElement.
	icon ifNotNil: [
		icon applyLayoutIn: (x @ y extent: icon measuredExtent) context: aBlElementBoundsUpdateContext ].

	bodyX := x + iconWidth.
	bodyWidth := (aRectangle width - padding width - iconWidth) max: 0.
	descriptionRegion := aRow descriptionRegionElement.
	editorRegion := aRow editorRegionElement.

	descriptionRegion ifNotNil: [
		descriptionRegion
			applyLayoutIn: (bodyX @ y extent: descriptionWidth @ descriptionRegion measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	editorRegion ifNotNil: [
		editorX := wrapped
			ifTrue: [ bodyX + descriptionWidth + aRow fieldGap ]
			ifFalse: [ bodyX + bodyWidth - editorWidth ].
		editorRegion
			applyLayoutIn: (editorX @ y extent: editorWidth @ editorRegion measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	self layoutIgnored: aRow context: aBlElementBoundsUpdateContext
]

Class {
	#name : 'CFMaDetailRowLayout',
	#superclass : 'BlLayout',
	#instVars : [
		'gap',
		'descriptionWidth',
		'contentWidth',
		'baseline'
	],
	#category : 'BVC-Foundation-Magritte-Detail-Layout',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Layout'
}

{ #category : 'constraints' }
CFMaDetailRowLayout class >> constraints [
	^ CFMaDetailRowLayoutConstraints new
]

{ #category : 'initialization' }
CFMaDetailRowLayout >> initialize [
	super initialize.
	gap := 12.0.
	descriptionWidth := 0.0.
	contentWidth := 0.0.
	baseline := nil
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> gap [
	^ gap
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> gap: aNumber [
	gap := aNumber asFloat
]

{ #category : 'private - children' }
CFMaDetailRowLayout >> childWithRole: aBlock in: anElement [
	^ anElement children accountedByLayout
		detect: [ :aChild | aBlock value: (aChild constraints at: self class) ]
		ifNone: [ nil ]
]

{ #category : 'private - children' }
CFMaDetailRowLayout >> descriptionChildIn: anElement [
	^ self childWithRole: [ :c | c isDescription ] in: anElement
]

{ #category : 'private - children' }
CFMaDetailRowLayout >> contentChildIn: anElement [
	^ self childWithRole: [ :c | c isContent ] in: anElement
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> measureNatural: aChild [
	aChild ifNil: [ ^ self ].
	self measureChild: aChild parentSpec: BlExtentMeasurementSpec unspecified
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> baselineFor: firstChild and: secondChild [
	| firstBaseline secondBaseline |
	firstBaseline := firstChild notNil and: [ firstChild supportsBaseline ]
		ifTrue: [ firstChild baselineOffset ]
		ifFalse: [ nil ].
	secondBaseline := secondChild notNil and: [ secondChild supportsBaseline ]
		ifTrue: [ secondChild baselineOffset ]
		ifFalse: [ nil ].
	(firstBaseline notNil and: [ secondBaseline notNil ]) ifFalse: [ ^ nil ].
	^ firstBaseline max: secondBaseline
]

{ #category : 'measure' }
CFMaDetailRowLayout >> measure: aRow with: anExtentSpec [
	| padding aDescription aContent availableWidth naturalDescriptionWidth naturalContentWidth usedGap desiredWidth contentHeight descriptionTop contentTop desiredHeight |
	padding := aRow padding.
	aDescription := self descriptionChildIn: aRow.
	aContent := self contentChildIn: aRow.

	self measureNatural: aDescription.
	self measureNatural: aContent.
	naturalDescriptionWidth := aDescription ifNil: [ 0.0 ] ifNotNil: [ aDescription measuredWidth ].
	naturalContentWidth := aContent ifNil: [ 0.0 ] ifNotNil: [ aContent measuredWidth ].
	usedGap := (aDescription notNil and: [ aContent notNil ]) ifTrue: [ gap ] ifFalse: [ 0.0 ].

	availableWidth := anExtentSpec widthSpec isUnspecified
		ifTrue: [ naturalDescriptionWidth + usedGap + naturalContentWidth ]
		ifFalse: [ (anExtentSpec widthSpec size - padding width) max: 0.0 ].

	descriptionWidth := naturalDescriptionWidth min: availableWidth.
	contentWidth := (availableWidth - descriptionWidth - usedGap) max: 0.0.

	aDescription ifNotNil: [
		self measureChild: aDescription parentSpec:
			((BlMeasurementSpec atMost: descriptionWidth) @ BlMeasurementSpec unspecified) ].
	aContent ifNotNil: [
		self measureChild: aContent parentSpec:
			((BlMeasurementSpec exact: contentWidth) @ BlMeasurementSpec unspecified) ].

	baseline := self baselineFor: aDescription and: aContent.
	descriptionTop := 0.0.
	contentTop := 0.0.
	baseline ifNotNil: [
		descriptionTop := baseline - aDescription baselineOffset.
		contentTop := baseline - aContent baselineOffset ].
	contentHeight := 0.0.
	aDescription ifNotNil: [ contentHeight := contentHeight max: descriptionTop + aDescription measuredHeight ].
	aContent ifNotNil: [ contentHeight := contentHeight max: contentTop + aContent measuredHeight ].

	desiredWidth := availableWidth + padding width.
	desiredHeight := contentHeight + padding height.
	aRow measuredExtent: (anExtentSpec sizeFor: desiredWidth @ desiredHeight).
	self measureIgnored: aRow with: (BlExtentMeasurementSpec exact: aRow measuredExtent)
]

{ #category : 'layout' }
CFMaDetailRowLayout >> layout: aRow in: aRectangle context: aBlElementBoundsUpdateContext [
	| padding aDescription aContent x y usedGap descriptionY contentY contentX innerHeight |
	padding := aRow padding.
	x := padding left.
	y := padding top.
	aDescription := self descriptionChildIn: aRow.
	aContent := self contentChildIn: aRow.
	usedGap := (aDescription notNil and: [ aContent notNil ]) ifTrue: [ gap ] ifFalse: [ 0.0 ].
	innerHeight := (aRectangle height - padding height) max: 0.0.

	descriptionY := y.
	contentY := y.
	baseline
		ifNil: [
			aDescription ifNotNil: [ descriptionY := y + ((innerHeight - aDescription measuredHeight) / 2.0) ].
			aContent ifNotNil: [ contentY := y + ((innerHeight - aContent measuredHeight) / 2.0) ] ]
		ifNotNil: [
			descriptionY := y + baseline - aDescription baselineOffset.
			contentY := y + baseline - aContent baselineOffset ].

	aDescription ifNotNil: [
		aDescription
			applyLayoutIn: (x @ descriptionY extent: descriptionWidth @ aDescription measuredHeight)
			context: aBlElementBoundsUpdateContext ].
	aContent ifNotNil: [
		contentX := x + descriptionWidth + usedGap.
		aContent
			applyLayoutIn: (contentX @ contentY extent: contentWidth @ aContent measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	self layoutIgnored: aRow context: aBlElementBoundsUpdateContext
]

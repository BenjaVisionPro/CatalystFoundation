Class {
	#name : 'CFMaDetailRowLayout',
	#superclass : 'BlLayout',
	#instVars : [
		'gap',
		'accessoryGap',
		'supportingGap',
		'wrapped',
		'bodyWidth',
		'descriptionWidth',
		'supportingWidth',
		'contentWidth',
		'firstLineHeight',
		'secondLineTop',
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
	accessoryGap := 6.0.
	supportingGap := 1.0.
	wrapped := false.
	bodyWidth := 0.0.
	descriptionWidth := 0.0.
	supportingWidth := 0.0.
	contentWidth := 0.0.
	firstLineHeight := 0.0.
	secondLineTop := 0.0.
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

{ #category : 'accessing' }
CFMaDetailRowLayout >> accessoryGap [
	^ accessoryGap
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> accessoryGap: aNumber [
	accessoryGap := aNumber asFloat
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> supportingGap [
	^ supportingGap
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> supportingGap: aNumber [
	supportingGap := aNumber asFloat
]

{ #category : 'private - children' }
CFMaDetailRowLayout >> childrenWithRole: aBlock in: anElement [
	^ anElement children accountedByLayout
		select: [ :aChild | aBlock value: (aChild constraints at: self class) ]
]

{ #category : 'private - children' }
CFMaDetailRowLayout >> firstChildWithRole: aBlock in: anElement [
	^ anElement children accountedByLayout
		detect: [ :aChild | aBlock value: (aChild constraints at: self class) ]
		ifNone: [ nil ]
]

{ #category : 'private - children' }
CFMaDetailRowLayout >> leadingChildrenIn: anElement [
	^ self childrenWithRole: [ :c | c isLeading ] in: anElement
]

{ #category : 'private - children' }
CFMaDetailRowLayout >> descriptionChildIn: anElement [
	^ self firstChildWithRole: [ :c | c isDescription ] in: anElement
]

{ #category : 'private - children' }
CFMaDetailRowLayout >> supportingChildIn: anElement [
	^ self firstChildWithRole: [ :c | c isSupporting ] in: anElement
]

{ #category : 'private - children' }
CFMaDetailRowLayout >> contentChildIn: anElement [
	^ self firstChildWithRole: [ :c | c isContent ] in: anElement
]

{ #category : 'private - children' }
CFMaDetailRowLayout >> accessoryChildrenIn: anElement [
	^ self childrenWithRole: [ :c | c isAccessory ] in: anElement
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> measureNatural: aChild [
	aChild ifNil: [ ^ self ].
	self measureChild: aChild parentSpec: BlExtentMeasurementSpec unspecified
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> measureNaturalAll: aCollection [
	aCollection do: [ :aChild | self measureNatural: aChild ]
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> totalMeasuredWidthOf: aCollection spacing: aSpacing [
	| aWidth |
	aCollection ifEmpty: [ ^ 0.0 ].
	aWidth := aCollection inject: 0.0 into: [ :sum :aChild | sum + aChild measuredWidth ].
	^ aWidth + ((aCollection size - 1) * aSpacing)
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> maximumMeasuredHeightOf: aCollection [
	^ aCollection
		inject: 0.0
		into: [ :aMaximum :aChild | aMaximum max: aChild measuredHeight ]
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> baselineFor: firstChild and: secondChild [
	| firstBaseline secondBaseline |
	firstBaseline := (firstChild notNil and: [ firstChild supportsBaseline ])
		ifTrue: [ firstChild baselineOffset ]
		ifFalse: [ nil ].
	secondBaseline := (secondChild notNil and: [ secondChild supportsBaseline ])
		ifTrue: [ secondChild baselineOffset ]
		ifFalse: [ nil ].
	(firstBaseline notNil and: [ secondBaseline notNil ]) ifFalse: [ ^ nil ].
	^ firstBaseline max: secondBaseline
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> measure: aChild widthAtMost: aWidth [
	aChild ifNil: [ ^ self ].
	self
		measureChild: aChild
		parentSpec: ((BlMeasurementSpec atMost: (aWidth max: 0.0)) @ BlMeasurementSpec unspecified)
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> measure: aChild widthExactly: aWidth [
	aChild ifNil: [ ^ self ].
	self
		measureChild: aChild
		parentSpec: ((BlMeasurementSpec exact: (aWidth max: 0.0)) @ BlMeasurementSpec unspecified)
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> bodyGapLeading: leadingChildren bodyPresent: bodyPresent accessories: accessoryChildren [
	| aGap |
	aGap := 0.0.
	(leadingChildren notEmpty and: [ bodyPresent ]) ifTrue: [ aGap := aGap + gap ].
	(accessoryChildren notEmpty and: [ bodyPresent ]) ifTrue: [ aGap := aGap + gap ].
	^ aGap
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> shouldWrapDescriptionWidth: naturalDescriptionWidth content: aContent [
	| fullWidthHeight inlineWidth inlineHeight |
	aContent ifNil: [ ^ false ].

	"BrEditor is horizontally match-parent by default, so an unspecified
	measurement is not a meaningful intrinsic-width test. Measure the real two
	candidates instead. If constraining the editor to the space beside the label
	makes it taller than it is with the whole body width, the editor has started
	to wrap internally. At that point the row wraps the editor instead."
	self measure: aContent widthExactly: bodyWidth.
	fullWidthHeight := aContent measuredHeight.
	inlineWidth := (bodyWidth - naturalDescriptionWidth - gap) max: 0.0.
	inlineWidth <= 0.0 ifTrue: [ ^ true ].
	self measure: aContent widthExactly: inlineWidth.
	inlineHeight := aContent measuredHeight.
	^ inlineHeight > fullWidthHeight
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> measureInlineDescription: aDescription supporting: aSupporting content: aContent naturalDescriptionWidth: naturalDescriptionWidth [
	| descriptionTop contentTop supportingHeight contentBottom supportingBottom |
	wrapped := false.
	descriptionWidth := naturalDescriptionWidth min: bodyWidth.
	contentWidth := aContent
		ifNil: [ 0.0 ]
		ifNotNil: [ (bodyWidth - descriptionWidth - gap) max: 0.0 ].
	supportingWidth := bodyWidth.

	self measure: aDescription widthAtMost: descriptionWidth.
	self measure: aContent widthExactly: contentWidth.
	self measure: aSupporting widthExactly: supportingWidth.

	baseline := self baselineFor: aDescription and: aContent.
	descriptionTop := 0.0.
	contentTop := 0.0.
	baseline ifNotNil: [
		descriptionTop := baseline - aDescription baselineOffset.
		contentTop := baseline - aContent baselineOffset ].
	firstLineHeight := 0.0.
	aDescription ifNotNil: [ firstLineHeight := firstLineHeight max: descriptionTop + aDescription measuredHeight ].
	aContent ifNotNil: [ firstLineHeight := firstLineHeight max: contentTop + aContent measuredHeight ].

	secondLineTop := aDescription
		ifNil: [ 0.0 ]
		ifNotNil: [ descriptionTop + aDescription measuredHeight + supportingGap ].
	supportingHeight := aSupporting ifNil: [ 0.0 ] ifNotNil: [ aSupporting measuredHeight ].
	contentBottom := aContent ifNil: [ 0.0 ] ifNotNil: [ contentTop + aContent measuredHeight ].
	supportingBottom := aSupporting ifNil: [ 0.0 ] ifNotNil: [ secondLineTop + supportingHeight ].
	^ firstLineHeight max: (contentBottom max: supportingBottom)
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> measureWrappedDescription: aDescription supporting: aSupporting content: aContent [
	| halfWidth secondLineHeight |
	wrapped := true.
	halfWidth := ((bodyWidth - gap) max: 0.0) / 2.0.
	descriptionWidth := bodyWidth.
	supportingWidth := halfWidth.
	contentWidth := halfWidth.

	self measure: aDescription widthAtMost: descriptionWidth.
	self measure: aSupporting widthExactly: supportingWidth.
	self measure: aContent widthExactly: contentWidth.

	baseline := nil.
	firstLineHeight := aDescription ifNil: [ 0.0 ] ifNotNil: [ aDescription measuredHeight ].
	secondLineTop := firstLineHeight + supportingGap.
	secondLineHeight := 0.0.
	aSupporting ifNotNil: [ secondLineHeight := secondLineHeight max: aSupporting measuredHeight ].
	aContent ifNotNil: [ secondLineHeight := secondLineHeight max: aContent measuredHeight ].
	^ secondLineTop + secondLineHeight
]

{ #category : 'measure' }
CFMaDetailRowLayout >> measure: aRow with: anExtentSpec [
	| padding leadingChildren aDescription aSupporting aContent accessoryChildren leadingWidth accessoriesWidth bodyPresent bodyGap naturalDescriptionWidth naturalContentWidth availableWidth bodyHeight contentHeight desiredWidth desiredHeight |
	padding := aRow padding.
	leadingChildren := self leadingChildrenIn: aRow.
	aDescription := self descriptionChildIn: aRow.
	aSupporting := self supportingChildIn: aRow.
	aContent := self contentChildIn: aRow.
	accessoryChildren := self accessoryChildrenIn: aRow.

	self measureNaturalAll: leadingChildren.
	self measureNatural: aDescription.
	self measureNatural: aContent.
	self measureNaturalAll: accessoryChildren.

	leadingWidth := self totalMeasuredWidthOf: leadingChildren spacing: accessoryGap.
	accessoriesWidth := self totalMeasuredWidthOf: accessoryChildren spacing: accessoryGap.
	bodyPresent := aDescription notNil or: [ aSupporting notNil or: [ aContent notNil ] ].
	bodyGap := self bodyGapLeading: leadingChildren bodyPresent: bodyPresent accessories: accessoryChildren.
	naturalDescriptionWidth := aDescription ifNil: [ 0.0 ] ifNotNil: [ aDescription measuredWidth ].
	naturalContentWidth := aContent ifNil: [ 0.0 ] ifNotNil: [ aContent measuredWidth ].

	availableWidth := anExtentSpec widthSpec isUnspecified
		ifTrue: [
			leadingWidth + bodyGap + accessoriesWidth + naturalDescriptionWidth
				+ (aContent ifNil: [ 0.0 ] ifNotNil: [ gap + naturalContentWidth ]) ]
		ifFalse: [ (anExtentSpec widthSpec size - padding width) max: 0.0 ].
	bodyWidth := (availableWidth - leadingWidth - accessoriesWidth - bodyGap) max: 0.0.

	bodyHeight := (aSupporting notNil and: [ aContent notNil and: [
		self shouldWrapDescriptionWidth: naturalDescriptionWidth content: aContent ] ])
		ifTrue: [ self measureWrappedDescription: aDescription supporting: aSupporting content: aContent ]
		ifFalse: [ self measureInlineDescription: aDescription supporting: aSupporting content: aContent naturalDescriptionWidth: naturalDescriptionWidth ].

	contentHeight := bodyHeight.
	contentHeight := contentHeight max: (self maximumMeasuredHeightOf: leadingChildren).
	contentHeight := contentHeight max: (self maximumMeasuredHeightOf: accessoryChildren).
	desiredWidth := availableWidth + padding width.
	desiredHeight := contentHeight + padding height.
	aRow measuredExtent: (anExtentSpec sizeFor: desiredWidth @ desiredHeight).
	self measureIgnored: aRow with: (BlExtentMeasurementSpec exact: aRow measuredExtent)
]

{ #category : 'private - layout' }
CFMaDetailRowLayout >> centeredYFor: aChild top: aTop innerHeight: anInnerHeight [
	^ aTop + ((anInnerHeight - aChild measuredHeight) / 2.0)
]

{ #category : 'private - layout' }
CFMaDetailRowLayout >> layoutInlineDescription: aDescription supporting: aSupporting content: aContent bodyX: bodyX bodyRight: bodyRight top: aTop context: aBlElementBoundsUpdateContext [
	| descriptionY contentY contentX |
	descriptionY := aTop.
	contentY := aTop.
	baseline ifNotNil: [
		descriptionY := aTop + baseline - aDescription baselineOffset.
		contentY := aTop + baseline - aContent baselineOffset ].

	aDescription ifNotNil: [
		aDescription
			applyLayoutIn: (bodyX @ descriptionY extent: aDescription measuredWidth @ aDescription measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	aContent ifNotNil: [
		contentX := bodyRight - aContent measuredWidth.
		aContent
			applyLayoutIn: (contentX @ contentY extent: aContent measuredExtent)
			context: aBlElementBoundsUpdateContext ].

	aSupporting ifNotNil: [
		aSupporting
			applyLayoutIn: (bodyX @ (aTop + secondLineTop) extent: supportingWidth @ aSupporting measuredHeight)
			context: aBlElementBoundsUpdateContext ]
]

{ #category : 'private - layout' }
CFMaDetailRowLayout >> layoutWrappedDescription: aDescription supporting: aSupporting content: aContent bodyX: bodyX top: aTop context: aBlElementBoundsUpdateContext [
	aDescription ifNotNil: [
		aDescription
			applyLayoutIn: (bodyX @ aTop extent: aDescription measuredWidth @ aDescription measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	aSupporting ifNotNil: [
		aSupporting
			applyLayoutIn: (bodyX @ (aTop + secondLineTop) extent: supportingWidth @ aSupporting measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	aContent ifNotNil: [
		aContent
			applyLayoutIn: ((bodyX + supportingWidth + gap) @ (aTop + secondLineTop)
				extent: contentWidth @ aContent measuredHeight)
			context: aBlElementBoundsUpdateContext ]
]

{ #category : 'layout' }
CFMaDetailRowLayout >> layout: aRow in: aRectangle context: aBlElementBoundsUpdateContext [
	| padding leadingChildren aDescription aSupporting aContent accessoryChildren x y innerHeight rightEdge bodyX bodyRight |
	padding := aRow padding.
	x := padding left.
	y := padding top.
	innerHeight := (aRectangle height - padding height) max: 0.0.
	leadingChildren := self leadingChildrenIn: aRow.
	aDescription := self descriptionChildIn: aRow.
	aSupporting := self supportingChildIn: aRow.
	aContent := self contentChildIn: aRow.
	accessoryChildren := self accessoryChildrenIn: aRow.

	leadingChildren doWithIndex: [ :aChild :anIndex |
		aChild
			applyLayoutIn: (x @ (self centeredYFor: aChild top: y innerHeight: innerHeight)
				extent: aChild measuredExtent)
			context: aBlElementBoundsUpdateContext.
		x := x + aChild measuredWidth.
		anIndex < leadingChildren size ifTrue: [ x := x + accessoryGap ] ].
	leadingChildren ifNotEmpty: [ x := x + gap ].
	bodyX := x.

	rightEdge := aRectangle width - padding right.
	accessoryChildren asArray reverseDo: [ :aChild |
		rightEdge := rightEdge - aChild measuredWidth.
		aChild
			applyLayoutIn: (rightEdge @ (self centeredYFor: aChild top: y innerHeight: innerHeight)
				extent: aChild measuredExtent)
			context: aBlElementBoundsUpdateContext.
		aChild == accessoryChildren first
			ifFalse: [ rightEdge := rightEdge - accessoryGap ] ].
	accessoryChildren ifNotEmpty: [ rightEdge := rightEdge - gap ].
	bodyRight := rightEdge.

	wrapped
		ifTrue: [
			self
				layoutWrappedDescription: aDescription
				supporting: aSupporting
				content: aContent
				bodyX: bodyX
				top: y
				context: aBlElementBoundsUpdateContext ]
		ifFalse: [
			self
				layoutInlineDescription: aDescription
				supporting: aSupporting
				content: aContent
				bodyX: bodyX
				bodyRight: bodyRight
				top: y
				context: aBlElementBoundsUpdateContext ].

	self layoutIgnored: aRow context: aBlElementBoundsUpdateContext
]

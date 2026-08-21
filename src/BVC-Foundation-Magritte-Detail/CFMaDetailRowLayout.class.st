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
CFMaDetailRowLayout >> measurePreferredWidth: aChild [
	"BrEditor is a BlInfiniteElement. BlInfiniteLayout records an unspecified
	width as zero, so an unspecified measure is not a valid preferred-width
	probe for editor content. A large at-most width gives infinite layouts a
	real finite measurement width while fit-content/fit-content-limited children
	remain free to shrink to their content via measureBasedOnChildren:."
	aChild ifNil: [ ^ self ].
	self
		measureChild: aChild
		parentSpec: ((BlMeasurementSpec atMost: SmallInteger maxVal asFloat)
			@ BlMeasurementSpec unspecified)
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
CFMaDetailRowLayout >> baselineOffsetFor: anElement [
	| aParagraphElement aTextElement |
	anElement ifNil: [ ^ nil ].
	anElement supportsBaseline ifTrue: [ ^ anElement baselineOffset ].

	(anElement isKindOf: BrEditorElement) ifFalse: [ ^ nil ].
	aParagraphElement := anElement children accountedByLayout
		detect: [ :each | each isKindOf: BrTextEditorParagraphElement ]
		ifNone: [ ^ nil ].
	aTextElement := aParagraphElement children accountedByLayout
		detect: [ :each | each isKindOf: BlTextElement ]
		ifNone: [ ^ nil ].

	"Editor text pieces use BlTextElement>>editorMeasurement, whose baseline is
	BlTextParagraphAscentLooseBaseline. Measure the real first text piece so the
	row aligns to the editor's actual first-line typography rather than a fixed
	pixel offset."
	aTextElement measure: BlExtentMeasurementSpec unspecified.
	^ anElement padding top + aParagraphElement padding top + aTextElement baselineOffset
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> baselineFor: firstChild and: secondChild [
	| firstBaseline secondBaseline |
	firstBaseline := self baselineOffsetFor: firstChild.
	secondBaseline := self baselineOffsetFor: secondChild.
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
CFMaDetailRowLayout >> shouldWrapDescriptionWidth: naturalDescriptionWidth contentWidth: preferredContentWidth [
	| inlineWidth |
	inlineWidth := (bodyWidth - naturalDescriptionWidth - gap) max: 0.0.
	inlineWidth <= 0.0 ifTrue: [ ^ true ].

	"Use the same half-pixel tolerance as BrEditorTextFlowLine>>hasSpaceFor:.
	If Brick would still regard the preferred width as fitting on the line, keep
	the editor inline. Otherwise move the editor as a whole before its text wraps."
	inlineWidth >= preferredContentWidth ifTrue: [ ^ false ].
	^ (inlineWidth closeTo: preferredContentWidth epsilon: 0.5) not
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
		descriptionTop := baseline - (self baselineOffsetFor: aDescription).
		contentTop := baseline - (self baselineOffsetFor: aContent) ].
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
	| halfWidth descriptionTop contentTop supportingBottom contentBottom |
	wrapped := true.
	halfWidth := ((bodyWidth - gap) max: 0.0) / 2.0.
	descriptionWidth := halfWidth.
	supportingWidth := halfWidth.
	contentWidth := halfWidth.

	self measure: aDescription widthAtMost: descriptionWidth.
	self measure: aSupporting widthExactly: supportingWidth.
	self measure: aContent widthExactly: contentWidth.

	baseline := self baselineFor: aDescription and: aContent.
	descriptionTop := 0.0.
	contentTop := 0.0.
	baseline ifNotNil: [
		descriptionTop := baseline - (self baselineOffsetFor: aDescription).
		contentTop := baseline - (self baselineOffsetFor: aContent) ].
	firstLineHeight := 0.0.
	aDescription ifNotNil: [ firstLineHeight := firstLineHeight max: descriptionTop + aDescription measuredHeight ].
	secondLineTop := aDescription
		ifNil: [ 0.0 ]
		ifNotNil: [ descriptionTop + aDescription measuredHeight + supportingGap ].
	supportingBottom := aSupporting ifNil: [ 0.0 ] ifNotNil: [ secondLineTop + aSupporting measuredHeight ].
	contentBottom := aContent ifNil: [ 0.0 ] ifNotNil: [ contentTop + aContent measuredHeight ].
	^ firstLineHeight max: (supportingBottom max: contentBottom)
]

{ #category : 'measure' }
CFMaDetailRowLayout >> measure: aRow with: anExtentSpec [
	| padding leadingChildren aDescription aSupporting aContent accessoryChildren leadingWidth accessoriesWidth bodyPresent bodyGap naturalDescriptionWidth preferredContentWidth availableWidth bodyHeight contentHeight desiredWidth desiredHeight |
	padding := aRow padding.
	leadingChildren := self leadingChildrenIn: aRow.
	aDescription := self descriptionChildIn: aRow.
	aSupporting := self supportingChildIn: aRow.
	aContent := self contentChildIn: aRow.
	accessoryChildren := self accessoryChildrenIn: aRow.

	self measureNaturalAll: leadingChildren.
	self measureNatural: aDescription.
	self measurePreferredWidth: aContent.
	self measureNaturalAll: accessoryChildren.

	leadingWidth := self totalMeasuredWidthOf: leadingChildren spacing: accessoryGap.
	accessoriesWidth := self totalMeasuredWidthOf: accessoryChildren spacing: accessoryGap.
	bodyPresent := aDescription notNil or: [ aSupporting notNil or: [ aContent notNil ] ].
	bodyGap := self bodyGapLeading: leadingChildren bodyPresent: bodyPresent accessories: accessoryChildren.
	naturalDescriptionWidth := aDescription ifNil: [ 0.0 ] ifNotNil: [ aDescription measuredWidth ].
	preferredContentWidth := aContent ifNil: [ 0.0 ] ifNotNil: [ aContent measuredWidth ].

	availableWidth := anExtentSpec widthSpec isUnspecified
		ifTrue: [
			leadingWidth + bodyGap + accessoriesWidth + naturalDescriptionWidth
				+ (aContent ifNil: [ 0.0 ] ifNotNil: [ gap + preferredContentWidth ]) ]
		ifFalse: [ (anExtentSpec widthSpec size - padding width) max: 0.0 ].
	bodyWidth := (availableWidth - leadingWidth - accessoriesWidth - bodyGap) max: 0.0.

	bodyHeight := (aSupporting notNil and: [ aContent notNil and: [
		self
			shouldWrapDescriptionWidth: naturalDescriptionWidth
			contentWidth: preferredContentWidth ] ])
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
		descriptionY := aTop + baseline - (self baselineOffsetFor: aDescription).
		contentY := aTop + baseline - (self baselineOffsetFor: aContent) ].

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
	| descriptionY contentY |
	descriptionY := aTop.
	contentY := aTop.
	baseline ifNotNil: [
		descriptionY := aTop + baseline - (self baselineOffsetFor: aDescription).
		contentY := aTop + baseline - (self baselineOffsetFor: aContent) ].

	aDescription ifNotNil: [
		aDescription
			applyLayoutIn: (bodyX @ descriptionY extent: descriptionWidth @ aDescription measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	aSupporting ifNotNil: [
		aSupporting
			applyLayoutIn: (bodyX @ (aTop + secondLineTop) extent: supportingWidth @ aSupporting measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	aContent ifNotNil: [
		aContent
			applyLayoutIn: ((bodyX + supportingWidth + gap) @ contentY
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
			applyLayoutIn: (x @ y extent: aChild measuredExtent)
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

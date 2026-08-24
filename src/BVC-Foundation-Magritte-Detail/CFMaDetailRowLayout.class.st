Class {
	#name : 'CFMaDetailRowLayout',
	#superclass : 'BlLayout',
	#instVars : [
		'gap',
		'leadingGap',
		'accessoryGap',
		'reservedAccessorySlots',
		'supportingGap',
		'supportingInset',
		'wrapped',
		'bodyWidth',
		'descriptionWidth',
		'supportingWidth',
		'contentWidth',
		'firstLineTop',
		'firstLineBottom',
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
	leadingGap := 8.0.
	accessoryGap := 6.0.
	reservedAccessorySlots := 0.
	supportingGap := 1.0.
	supportingInset := 1.0.
	wrapped := false.
	bodyWidth := 0.0.
	descriptionWidth := 0.0.
	supportingWidth := 0.0.
	contentWidth := 0.0.
	firstLineTop := 0.0.
	firstLineBottom := 0.0.
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
CFMaDetailRowLayout >> leadingGap [
	^ leadingGap
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> leadingGap: aNumber [
	leadingGap := aNumber asFloat
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> accessoryGap [
	^ accessoryGap
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> accessoryGap: aNumber [
	accessoryGap := aNumber asFloat
]



{ #category : 'private - metrics' }
CFMaDetailRowLayout >> accessorySlotWidth [
	^ 16.0
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> reservedAccessorySlots [
	^ reservedAccessorySlots
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> reservedAccessorySlots: aNumber [
	self
		assert: [ aNumber isInteger and: [ aNumber >= 0 ] ]
		description: [ 'The number of reserved accessory slots must be a non-negative integer' ].
	reservedAccessorySlots := aNumber
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> reservedAccessoriesWidth [
	reservedAccessorySlots = 0 ifTrue: [ ^ 0.0 ].
	^ (reservedAccessorySlots * self accessorySlotWidth)
		+ ((reservedAccessorySlots - 1) * accessoryGap)
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> supportingGap [
	^ supportingGap
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> supportingGap: aNumber [
	supportingGap := aNumber asFloat
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> supportingInset [
	^ supportingInset
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> supportingInset: aNumber [
	supportingInset := aNumber asFloat
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

{ #category : 'private - children' }
CFMaDetailRowLayout >> trailingChildIn: anElement [
	^ self firstChildWithRole: [ :c | c isTrailing ] in: anElement
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
CFMaDetailRowLayout >> bodyGapLeading: leadingChildren bodyPresent: bodyPresent accessorySpacePresent: accessorySpacePresent [
	| aGap |
	aGap := 0.0.
	(leadingChildren notEmpty and: [ bodyPresent ]) ifTrue: [ aGap := aGap + leadingGap ].
	(accessorySpacePresent and: [ bodyPresent ]) ifTrue: [ aGap := aGap + gap ].
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
CFMaDetailRowLayout >> contentUsesAvailableWidth: aContent [
	aContent ifNil: [ ^ false ].
	^ aContent constraints horizontal resizer isMatchParent
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> measureInlineDescription: aDescription supporting: aSupporting content: aContent naturalDescriptionWidth: naturalDescriptionWidth [
	| descriptionTop contentTop supportingHeight contentBottom supportingBottom |

	wrapped := false.
	descriptionWidth := naturalDescriptionWidth min: bodyWidth.
	contentWidth := aContent
		ifNil: [ 0.0 ]
		ifNotNil: [ (bodyWidth - descriptionWidth - gap) max: 0.0 ].
	supportingWidth := (bodyWidth - supportingInset
		- (aContent ifNil: [ 0.0 ] ifNotNil: [ gap + aContent measuredWidth ])) max: 0.0.

	self measure: aDescription widthAtMost: descriptionWidth.
	(self contentUsesAvailableWidth: aContent)
		ifTrue: [ self measure: aContent widthExactly: contentWidth ]
		ifFalse: [ self measure: aContent widthAtMost: contentWidth ].
	self measure: aSupporting widthExactly: supportingWidth.

	baseline := self baselineFor: aDescription and: aContent.
	descriptionTop := 0.0.
	contentTop := 0.0.
	baseline ifNotNil: [
		descriptionTop := baseline - (self baselineOffsetFor: aDescription).
		contentTop := baseline - (self baselineOffsetFor: aContent) ].
	firstLineTop := 0.0.
	firstLineBottom := 0.0.
	(aDescription notNil or: [ aContent notNil ]) ifTrue: [
		firstLineTop := {
			aDescription ifNil: [ nil ] ifNotNil: [ descriptionTop ].
			aContent ifNil: [ nil ] ifNotNil: [ contentTop ] }
				reject: #isNil;
				min.
		firstLineBottom := {
			aDescription ifNil: [ nil ] ifNotNil: [ descriptionTop + aDescription measuredHeight ].
			aContent ifNil: [ nil ] ifNotNil: [ contentTop + aContent measuredHeight ] }
				reject: #isNil;
				max ].

	secondLineTop := aDescription
		ifNil: [ 0.0 ]
		ifNotNil: [ descriptionTop + aDescription measuredHeight + supportingGap ].
	supportingHeight := aSupporting ifNil: [ 0.0 ] ifNotNil: [ aSupporting measuredHeight ].
	contentBottom := aContent ifNil: [ 0.0 ] ifNotNil: [ contentTop + aContent measuredHeight ].
	supportingBottom := aSupporting ifNil: [ 0.0 ] ifNotNil: [ secondLineTop + supportingHeight ].
	^ firstLineBottom max: (contentBottom max: supportingBottom)
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> measureWrappedDescription: aDescription supporting: aSupporting content: aContent [
	| halfWidth descriptionTop contentTop supportingBottom contentBottom |

	wrapped := true.
	halfWidth := ((bodyWidth - gap) max: 0.0) / 2.0.
	descriptionWidth := halfWidth.
	supportingWidth := (halfWidth - supportingInset) max: 0.0.
	contentWidth := halfWidth.

	self measure: aDescription widthAtMost: descriptionWidth.
	self measure: aSupporting widthExactly: supportingWidth.
	(self contentUsesAvailableWidth: aContent)
		ifTrue: [ self measure: aContent widthExactly: contentWidth ]
		ifFalse: [ self measure: aContent widthAtMost: contentWidth ].

	baseline := self baselineFor: aDescription and: aContent.
	descriptionTop := 0.0.
	contentTop := 0.0.
	baseline ifNotNil: [
		descriptionTop := baseline - (self baselineOffsetFor: aDescription).
		contentTop := baseline - (self baselineOffsetFor: aContent) ].
	firstLineTop := 0.0.
	firstLineBottom := 0.0.
	(aDescription notNil or: [ aContent notNil ]) ifTrue: [
		firstLineTop := {
			aDescription ifNil: [ nil ] ifNotNil: [ descriptionTop ].
			aContent ifNil: [ nil ] ifNotNil: [ contentTop ] }
				reject: #isNil;
				min.
		firstLineBottom := {
			aDescription ifNil: [ nil ] ifNotNil: [ descriptionTop + aDescription measuredHeight ].
			aContent ifNil: [ nil ] ifNotNil: [ contentTop + aContent measuredHeight ] }
				reject: #isNil;
				max ].
	secondLineTop := aDescription
		ifNil: [ 0.0 ]
		ifNotNil: [ descriptionTop + aDescription measuredHeight + supportingGap ].
	supportingBottom := aSupporting ifNil: [ 0.0 ] ifNotNil: [ secondLineTop + aSupporting measuredHeight ].
	contentBottom := aContent ifNil: [ 0.0 ] ifNotNil: [ contentTop + aContent measuredHeight ].
	^ firstLineBottom max: (supportingBottom max: contentBottom)
]

{ #category : 'measure' }
CFMaDetailRowLayout >> measure: aRow with: anExtentSpec [
	| padding leadingChildren aDescription aSupporting aContent accessoryChildren aTrailing leadingWidth actualAccessoriesWidth accessoriesWidth accessorySpacePresent trailingWidth trailingGap bodyPresent bodyGap naturalDescriptionWidth preferredContentWidth availableWidth bodyHeight contentHeight desiredWidth desiredHeight |
	padding := aRow padding.
	leadingChildren := self leadingChildrenIn: aRow.
	aDescription := self descriptionChildIn: aRow.
	aSupporting := self supportingChildIn: aRow.
	aContent := self contentChildIn: aRow.
	accessoryChildren := self accessoryChildrenIn: aRow.
	aTrailing := self trailingChildIn: aRow.

	self measureNaturalAll: leadingChildren.
	self measureNatural: aDescription.
	self measurePreferredWidth: aContent.
	self measureNaturalAll: accessoryChildren.
	self measureNatural: aTrailing.

	leadingWidth := self totalMeasuredWidthOf: leadingChildren spacing: accessoryGap.
	actualAccessoriesWidth := self totalMeasuredWidthOf: accessoryChildren spacing: accessoryGap.
	accessoriesWidth := actualAccessoriesWidth max: self reservedAccessoriesWidth.
	accessorySpacePresent := accessoriesWidth > 0.0.
	trailingWidth := aTrailing ifNil: [ 0.0 ] ifNotNil: [ aTrailing measuredWidth ].
	trailingGap := (aTrailing notNil and: [ accessorySpacePresent ]) ifTrue: [ accessoryGap ] ifFalse: [ 0.0 ].
	bodyPresent := aDescription notNil or: [ aSupporting notNil or: [ aContent notNil ] ].
	bodyGap := self bodyGapLeading: leadingChildren bodyPresent: bodyPresent accessorySpacePresent: accessorySpacePresent.
	(aTrailing notNil and: [ bodyPresent and: [ accessorySpacePresent not ] ])
		ifTrue: [ bodyGap := bodyGap + gap ].
	naturalDescriptionWidth := aDescription ifNil: [ 0.0 ] ifNotNil: [ aDescription measuredWidth ].
	preferredContentWidth := aContent ifNil: [ 0.0 ] ifNotNil: [ aContent measuredWidth ].

	availableWidth := anExtentSpec widthSpec isUnspecified
		ifTrue: [
			leadingWidth + bodyGap + accessoriesWidth + trailingGap + trailingWidth + naturalDescriptionWidth
				+ (aContent ifNil: [ 0.0 ] ifNotNil: [ gap + preferredContentWidth ]) ]
		ifFalse: [ (anExtentSpec widthSpec size - padding width) max: 0.0 ].
	bodyWidth := (availableWidth - leadingWidth - accessoriesWidth - trailingGap - trailingWidth - bodyGap) max: 0.0.

	bodyHeight := (aSupporting notNil and: [ aContent notNil and: [
		self
			shouldWrapDescriptionWidth: naturalDescriptionWidth
			contentWidth: preferredContentWidth ] ])
		ifTrue: [ self measureWrappedDescription: aDescription supporting: aSupporting content: aContent ]
		ifFalse: [ self measureInlineDescription: aDescription supporting: aSupporting content: aContent naturalDescriptionWidth: naturalDescriptionWidth ].

	contentHeight := bodyHeight.
	leadingChildren ifNotEmpty: [
		| leadingTop |
		leadingTop := (aDescription notNil and: [ baseline notNil ])
			ifTrue: [ baseline - (self baselineOffsetFor: aDescription) ]
			ifFalse: [ 0.0 ].
		contentHeight := contentHeight max: (leadingTop + (self maximumMeasuredHeightOf: leadingChildren)) ].
	contentHeight := contentHeight max: (self maximumMeasuredHeightOf: accessoryChildren).
	aTrailing ifNotNil: [ contentHeight := contentHeight max: aTrailing measuredHeight ].
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
CFMaDetailRowLayout >> firstLineYFor: aChild top: aTop [
	^ aTop + firstLineTop
		+ (((firstLineBottom - firstLineTop) - aChild measuredHeight) / 2.0)
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
			applyLayoutIn: ((bodyX + supportingInset) @ (aTop + secondLineTop) extent: supportingWidth @ aSupporting measuredHeight)
			context: aBlElementBoundsUpdateContext ]
]

{ #category : 'private - layout' }
CFMaDetailRowLayout >> layoutWrappedDescription: aDescription supporting: aSupporting content: aContent bodyX: bodyX top: aTop context: aBlElementBoundsUpdateContext [
	| descriptionY contentY contentX |
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
			applyLayoutIn: ((bodyX + supportingInset) @ (aTop + secondLineTop) extent: supportingWidth @ aSupporting measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	aContent ifNotNil: [
		(self contentUsesAvailableWidth: aContent)
			ifTrue: [
				contentX := bodyX + supportingWidth + supportingInset + gap.
				aContent
					applyLayoutIn: (contentX @ contentY extent: contentWidth @ aContent measuredHeight)
					context: aBlElementBoundsUpdateContext ]
			ifFalse: [
				contentX := bodyX + supportingWidth + supportingInset + gap + (contentWidth - aContent measuredWidth).
				aContent
					applyLayoutIn: (contentX @ contentY extent: aContent measuredExtent)
					context: aBlElementBoundsUpdateContext ] ]
]

{ #category : 'layout' }
CFMaDetailRowLayout >> layout: aRow in: aRectangle context: aBlElementBoundsUpdateContext [
	| padding leadingChildren aDescription aSupporting aContent accessoryChildren aTrailing x y innerHeight rightEdge bodyX bodyRight leadingY actualAccessoriesWidth accessoriesWidth accessorySpacePresent accessoryAreaRight |
	padding := aRow padding.
	x := padding left.
	y := padding top.
	innerHeight := (aRectangle height - padding height) max: 0.0.
	leadingChildren := self leadingChildrenIn: aRow.
	aDescription := self descriptionChildIn: aRow.
	aSupporting := self supportingChildIn: aRow.
	aContent := self contentChildIn: aRow.
	accessoryChildren := self accessoryChildrenIn: aRow.
	aTrailing := self trailingChildIn: aRow.

	leadingY := (aDescription notNil and: [ baseline notNil ])
		ifTrue: [ y + baseline - (self baselineOffsetFor: aDescription) ]
		ifFalse: [ y ].
	leadingChildren doWithIndex: [ :aChild :anIndex |
		aChild
			applyLayoutIn: (x @ leadingY extent: aChild measuredExtent)
			context: aBlElementBoundsUpdateContext.
		x := x + aChild measuredWidth.
		anIndex < leadingChildren size ifTrue: [ x := x + accessoryGap ] ].
	leadingChildren ifNotEmpty: [ x := x + leadingGap ].
	bodyX := x.

	rightEdge := aRectangle width - padding right.
	actualAccessoriesWidth := self totalMeasuredWidthOf: accessoryChildren spacing: accessoryGap.
	accessoriesWidth := actualAccessoriesWidth max: self reservedAccessoriesWidth.
	accessorySpacePresent := accessoriesWidth > 0.0.
	aTrailing ifNotNil: [
		rightEdge := rightEdge - aTrailing measuredWidth.
		aTrailing
			applyLayoutIn: (rightEdge @ (self centeredYFor: aTrailing top: y innerHeight: innerHeight)
				extent: aTrailing measuredExtent)
			context: aBlElementBoundsUpdateContext.
		accessorySpacePresent ifTrue: [ rightEdge := rightEdge - accessoryGap ] ].
	accessoryAreaRight := rightEdge.
	accessoryChildren asArray reverseDo: [ :aChild |
		rightEdge := rightEdge - aChild measuredWidth.
		aChild
			applyLayoutIn: (rightEdge @ (self firstLineYFor: aChild top: y)
				extent: aChild measuredExtent)
			context: aBlElementBoundsUpdateContext.
		aChild == accessoryChildren first
			ifFalse: [ rightEdge := rightEdge - accessoryGap ] ].
	rightEdge := accessoryAreaRight - accessoriesWidth.
	(accessorySpacePresent or: [ aTrailing notNil ]) ifTrue: [ rightEdge := rightEdge - gap ].
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

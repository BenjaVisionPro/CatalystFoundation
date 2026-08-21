Class {
	#name : 'CFMaDetailRowLayout',
	#superclass : 'BlLayout',
	#instVars : [
		'gap',
		'accessoryGap',
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
	accessoryGap := 6.0.
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

{ #category : 'accessing' }
CFMaDetailRowLayout >> accessoryGap [
	^ accessoryGap
]

{ #category : 'accessing' }
CFMaDetailRowLayout >> accessoryGap: aNumber [
	accessoryGap := aNumber asFloat
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
CFMaDetailRowLayout >> regionCountLeading: leadingChildren description: aDescription content: aContent accessories: accessoryChildren [
	| aCount |
	aCount := 0.
	leadingChildren ifNotEmpty: [ aCount := aCount + 1 ].
	aDescription ifNotNil: [ aCount := aCount + 1 ].
	aContent ifNotNil: [ aCount := aCount + 1 ].
	accessoryChildren ifNotEmpty: [ aCount := aCount + 1 ].
	^ aCount
]

{ #category : 'private - measurement' }
CFMaDetailRowLayout >> maximumMeasuredHeightOf: aCollection [
	^ aCollection
		inject: 0.0
		into: [ :aMaximum :aChild | aMaximum max: aChild measuredHeight ]
]

{ #category : 'measure' }
CFMaDetailRowLayout >> measure: aRow with: anExtentSpec [
	| padding leadingChildren aDescription aContent accessoryChildren leadingWidth accessoriesWidth regionCount regionGaps availableWidth flexibleWidth naturalDescriptionWidth naturalContentWidth contentIsFlexible desiredWidth contentHeight descriptionTop contentTop desiredHeight |
	padding := aRow padding.
	leadingChildren := self leadingChildrenIn: aRow.
	aDescription := self descriptionChildIn: aRow.
	aContent := self contentChildIn: aRow.
	accessoryChildren := self accessoryChildrenIn: aRow.

	self measureNaturalAll: leadingChildren.
	self measureNatural: aDescription.
	self measureNatural: aContent.
	self measureNaturalAll: accessoryChildren.

	leadingWidth := self totalMeasuredWidthOf: leadingChildren spacing: accessoryGap.
	accessoriesWidth := self totalMeasuredWidthOf: accessoryChildren spacing: accessoryGap.
	regionCount := self
		regionCountLeading: leadingChildren
		description: aDescription
		content: aContent
		accessories: accessoryChildren.
	regionGaps := ((regionCount - 1) max: 0) * gap.

	naturalDescriptionWidth := aDescription ifNil: [ 0.0 ] ifNotNil: [ aDescription measuredWidth ].
	naturalContentWidth := aContent ifNil: [ 0.0 ] ifNotNil: [ aContent measuredWidth ].

	availableWidth := anExtentSpec widthSpec isUnspecified
		ifTrue: [ leadingWidth + regionGaps + naturalDescriptionWidth + naturalContentWidth + accessoriesWidth ]
		ifFalse: [ (anExtentSpec widthSpec size - padding width) max: 0.0 ].
	flexibleWidth := (availableWidth - leadingWidth - accessoriesWidth - regionGaps) max: 0.0.

	contentIsFlexible := (aContent notNil
		and: [ aContent constraints horizontal resizer isMatchParent ]).

	aContent
		ifNil: [
			contentWidth := 0.0.
			descriptionWidth := naturalDescriptionWidth min: flexibleWidth ]
		ifNotNil: [
			contentIsFlexible
				ifTrue: [
				descriptionWidth := naturalDescriptionWidth min: flexibleWidth.
				contentWidth := (flexibleWidth - descriptionWidth) max: 0.0 ]
				ifFalse: [
				contentWidth := naturalContentWidth min: flexibleWidth.
				descriptionWidth := naturalDescriptionWidth min: ((flexibleWidth - contentWidth) max: 0.0) ] ].

	aDescription ifNotNil: [
		self measureChild: aDescription parentSpec:
			((BlMeasurementSpec atMost: descriptionWidth) @ BlMeasurementSpec unspecified) ].
	aContent ifNotNil: [
		self measureChild: aContent parentSpec:
			(((contentIsFlexible
				ifTrue: [ BlMeasurementSpec exact: contentWidth ]
				ifFalse: [ BlMeasurementSpec atMost: contentWidth ]))
				@ BlMeasurementSpec unspecified) ].

	baseline := self baselineFor: aDescription and: aContent.
	descriptionTop := 0.0.
	contentTop := 0.0.
	baseline ifNotNil: [
		descriptionTop := baseline - aDescription baselineOffset.
		contentTop := baseline - aContent baselineOffset ].

	contentHeight := self maximumMeasuredHeightOf: leadingChildren.
	contentHeight := contentHeight max: (self maximumMeasuredHeightOf: accessoryChildren).
	aDescription ifNotNil: [ contentHeight := contentHeight max: descriptionTop + aDescription measuredHeight ].
	aContent ifNotNil: [ contentHeight := contentHeight max: contentTop + aContent measuredHeight ].

	desiredWidth := availableWidth + padding width.
	desiredHeight := contentHeight + padding height.
	aRow measuredExtent: (anExtentSpec sizeFor: desiredWidth @ desiredHeight).
	self measureIgnored: aRow with: (BlExtentMeasurementSpec exact: aRow measuredExtent)
]

{ #category : 'private - layout' }
CFMaDetailRowLayout >> centeredYFor: aChild top: aTop innerHeight: anInnerHeight [
	^ aTop + ((anInnerHeight - aChild measuredHeight) / 2.0)
]

{ #category : 'layout' }
CFMaDetailRowLayout >> layout: aRow in: aRectangle context: aBlElementBoundsUpdateContext [
	| padding leadingChildren aDescription aContent accessoryChildren x y innerHeight rightEdge descriptionY contentY contentX |
	padding := aRow padding.
	x := padding left.
	y := padding top.
	innerHeight := (aRectangle height - padding height) max: 0.0.
	leadingChildren := self leadingChildrenIn: aRow.
	aDescription := self descriptionChildIn: aRow.
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

	descriptionY := y.
	contentY := y.
	baseline
		ifNil: [
			aDescription ifNotNil: [ descriptionY := self centeredYFor: aDescription top: y innerHeight: innerHeight ].
			aContent ifNotNil: [ contentY := self centeredYFor: aContent top: y innerHeight: innerHeight ] ]
		ifNotNil: [
			descriptionY := y + baseline - aDescription baselineOffset.
			contentY := y + baseline - aContent baselineOffset ].

	aDescription ifNotNil: [
		aDescription
			applyLayoutIn: (x @ descriptionY extent: descriptionWidth @ aDescription measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	aContent ifNotNil: [
		contentX := aContent constraints horizontal resizer isMatchParent
			ifTrue: [ x + descriptionWidth + (aDescription ifNil: [ 0.0 ] ifNotNil: [ gap ]) ]
			ifFalse: [ rightEdge - contentWidth ].
		aContent
			applyLayoutIn: (contentX @ contentY extent: contentWidth @ aContent measuredHeight)
			context: aBlElementBoundsUpdateContext ].

	self layoutIgnored: aRow context: aBlElementBoundsUpdateContext
]

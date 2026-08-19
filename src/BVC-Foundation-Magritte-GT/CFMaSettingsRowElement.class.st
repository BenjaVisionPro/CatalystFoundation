Class {
	#name : 'CFMaSettingsRowElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'icon',
		'label',
		'comment',
		'field',
		'fieldState',
		'multiline',
		'labelColumn',
		'fieldColumn',
		'topLine',
		'wrappedMultiline',
		'cardTopInset',
		'cardBottomInset'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'initialization' }
CFMaSettingsRowElement >> initialize [
	super initialize.
	multiline := false.
	wrappedMultiline := false.
	cardTopInset := 0.
	cardBottomInset := 0.
	self
		hMatchParent;
		vFitContent;
		updatePadding;
		addAptitude: CFMaActiveSelectionAptitude new;
		addAptitude: CFMaSettingsRowAptitude new
]


{ #category : 'private - card geometry' }
CFMaSettingsRowElement >> cardBottomInset: aNumber [
	cardBottomInset := aNumber.
	self updatePadding
]

{ #category : 'private - card geometry' }
CFMaSettingsRowElement >> cardTopInset: aNumber [
	cardTopInset := aNumber.
	self updatePadding
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> updatePadding [
	self padding: (BlInsets
		top: self topInset + cardTopInset
		left: self horizontalInset
		bottom: self bottomInset + cardBottomInset
		right: self trailingInset)
]

{ #category : 'accessing' }
CFMaSettingsRowElement >> fieldState [
	^ fieldState
]

{ #category : 'accessing' }
CFMaSettingsRowElement >> fieldState: aFieldState [
	fieldState := aFieldState
]

{ #category : 'initialization' }
CFMaSettingsRowElement >> icon: anIcon label: aLabel comment: aComment field: aField multiline: aBoolean [
	icon := anIcon.
	label := aLabel.
	comment := aComment.
	field := aField.
	self updatePadding.
	multiline := aBoolean.
	multiline
		ifTrue: [ self buildMultiline ]
		ifFalse: [ self buildStandard ]
]

{ #category : 'private - building' }
CFMaSettingsRowElement >> buildStandard [
	| aContent aLeading aTrailing |
	(label isNil and: [ comment isNil ]) ifTrue: [
		field
			hMatchParent;
			vFitContent.
		self addChild: field.
		^ self ].

	aLeading := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets top: self labelVerticalAdjustment);
		yourself.
	label ifNotNil: [ aLeading addChild: label ].
	comment ifNotNil: [ aLeading addChild: comment ].
	aLeading constraintsDo: [ :c |
		c linear weight: 1.
		comment
			ifNil: [ c linear vertical alignCenter ]
			ifNotNil: [ c linear vertical alignTop ] ].

	field
		hFitContent;
		vFitContent.
	(field isKindOf: CFMaSettingsBooleanElement)
		ifTrue: [ field margin: (BlInsets right: self horizontalInset - self trailingInset) ]
		ifFalse: [ field margin: (BlInsets
			top: self fieldVerticalAdjustment
			right: self standardEditorTrailingAdjustment
			bottom: 0
			left: 0) ].

	aTrailing := BrFrame new
		hFitContent;
		vFitContent;
		margin: BlInsets empty;
		padding: BlInsets empty;
		addChild: field;
		yourself.
	aTrailing constraintsDo: [ :c |
		comment
			ifNil: [ c linear vertical alignCenter ]
			ifNotNil: [ c linear vertical alignTop ] ].
	field constraintsDo: [ :c |
		c frame horizontal alignRight.
		(field isKindOf: CFMaSettingsBooleanElement)
			ifTrue: [ c frame vertical alignCenter ]
			ifFalse: [ c frame vertical alignTop ] ].

	aContent := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		padding: BlInsets empty;
		yourself.
	icon ifNotNil: [
		comment
			ifNil: [
				icon margin: (BlInsets top: 0 right: self iconGap bottom: 0 left: 0).
				icon constraintsDo: [ :c | c linear vertical alignCenter ] ]
			ifNotNil: [
				icon margin: (BlInsets top: self labelVerticalAdjustment + 2 right: self iconGap bottom: 0 left: 0).
				icon constraintsDo: [ :c | c linear vertical alignTop ] ].
		aContent addChild: icon ].
	aContent
		addChild: aLeading;
		addChild: aTrailing.

	self addChild: aContent
]

{ #category : 'private - building' }
CFMaSettingsRowElement >> buildMultiline [
	labelColumn := BrVerticalPane new
		hFitContent;
		vFitContent;
		margin: (BlInsets top: self labelVerticalAdjustment);
		yourself.
	label ifNotNil: [ labelColumn addChild: label ].

	field
		hMatchParent;
		vFitContent;
		clipChildren: false;
		margin: BlInsets empty;
		padding: (BlInsets right: self multilineEditorTrailingInset).

	fieldColumn := BrFrame new
		hMatchParent;
		vFitContent;
		clipChildren: false;
		margin: (BlInsets top: self fieldVerticalAdjustment);
		padding: (BlInsets left: self compactFieldGap);
		addChild: field;
		yourself.
	fieldColumn constraintsDo: [ :c |
		c linear weight: 1.
		c linear vertical alignTop ].
	field constraintsDo: [ :c |
		c frame vertical alignTop ].

	topLine := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		clipChildren: false;
		yourself.
	icon ifNotNil: [
		icon margin: (BlInsets top: self labelVerticalAdjustment + 2 right: self iconGap bottom: 0 left: 0).
		topLine addChild: icon ].
	topLine
		addChild: labelColumn;
		addChild: fieldColumn.
	self addChild: topLine.
	comment ifNotNil: [ self addChild: comment ].

	self
		when: BlElementExtentChangedEvent
		do: [ :anEvent | self scheduleMultilineArrangementUpdate ].
	field
		when: BlElementExtentChangedEvent
		do: [ :anEvent | self scheduleMultilineArrangementUpdate ].
	self scheduleMultilineArrangementUpdate
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> scheduleMultilineArrangementUpdate [
	self enqueueTask: (BlTaskAction new action: [ self updateMultilineArrangement ])
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> updateMultilineArrangement [
	| shouldWrap |
	shouldWrap := self shouldUseWrappedMultilineArrangement.
	shouldWrap = wrappedMultiline ifTrue: [ ^ self ].

	wrappedMultiline := shouldWrap.
	wrappedMultiline
		ifTrue: [ self useWrappedMultilineArrangement ]
		ifFalse: [ self useCompactMultilineArrangement ]
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> shouldUseWrappedMultilineArrangement [
	| paragraphs availableWidth labelWidth fieldWidth requiredWidth |
	paragraphs := field allChildrenBreadthFirstSelect: [ :each |
		each isKindOf: CFMaSettingsRightAlignedParagraphElement ].
	paragraphs isEmpty ifTrue: [ ^ false ].

	"More than one paragraph represents explicit multiline content."
	paragraphs size > 1 ifTrue: [ ^ true ].

	availableWidth := (self extent x - self padding width) max: 0.
	availableWidth <= 0 ifTrue: [ ^ false ].

	labelWidth := label
		ifNil: [ 0 ]
		ifNotNil: [ label measuredWidth ].
	fieldWidth := paragraphs first unwrappedWidth + field padding width.
	requiredWidth := labelWidth + self compactFieldGap + fieldWidth.

	^ requiredWidth > availableWidth
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> useCompactMultilineArrangement [
	comment ifNotNil: [
		comment hasParent ifTrue: [
			comment parent == self ifFalse: [
				comment parent removeChild: comment.
				self addChild: comment ] ] ].
	labelColumn
		hFitContent;
		padding: BlInsets empty;
		constraintsDo: [ :c |
			c linear weight: 0.
			c linear vertical alignTop ].
	fieldColumn
		padding: (BlInsets left: self compactFieldGap);
		constraintsDo: [ :c |
			c linear weight: 1.
			c linear vertical alignTop ]
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> useWrappedMultilineArrangement [
	comment ifNotNil: [
		comment hasParent ifTrue: [
			comment parent == labelColumn ifFalse: [
				comment parent removeChild: comment.
				labelColumn addChild: comment ] ] ].
	labelColumn
		hMatchParent;
		padding: (BlInsets right: self wrappedColumnGap / 2);
		constraintsDo: [ :c |
			c linear weight: 1.
			c linear vertical alignTop ].
	fieldColumn
		padding: (BlInsets left: self wrappedColumnGap / 2);
		constraintsDo: [ :c |
			c linear weight: 1.
			c linear vertical alignTop ]
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> iconGap [
	^ 10
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> bottomInset [
	icon ifNil: [ ^ 6 ].
	comment ifNil: [ ^ 3 ].
	^ 5
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> compactFieldGap [
	^ 12
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> editorTextHorizontalInset [
	^ 0
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> trailingInset [
	^ 2
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> labelVerticalAdjustment [
	^ 1
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> fieldVerticalAdjustment [
	^ -3
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> horizontalInset [
	^ 8
]


{ #category : 'private - metrics' }
CFMaSettingsRowElement >> multilineEditorTrailingInset [
	^ 6
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> standardEditorTrailingAdjustment [
	^ -2
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> topInset [
	^ icon
		ifNil: [ 5 ]
		ifNotNil: [ 4 ]
]


{ #category : 'private - metrics' }
CFMaSettingsRowElement >> wrappedColumnGap [
	^ 12
]

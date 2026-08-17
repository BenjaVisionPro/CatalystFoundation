Class {
	#name : 'CFMaSettingsRowElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'label',
		'comment',
		'field',
		'multiline',
		'labelColumn',
		'fieldColumn',
		'topLine',
		'wrappedMultiline'
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
	self
		hMatchParent;
		vFitContent;
		padding: (BlInsets
			top: self topInset
			left: self horizontalInset
			bottom: self bottomInset
			right: self trailingInset);
		addAptitude: CFMaActiveSelectionAptitude new;
		addAptitude: CFMaSettingsRowAptitude new
]

{ #category : 'initialization' }
CFMaSettingsRowElement >> label: aLabel comment: aComment field: aField multiline: aBoolean [
	label := aLabel.
	comment := aComment.
	field := aField.
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
		c linear vertical alignTop ].

	field
		hFitContent;
		vFitContent.
	(field isKindOf: CFMaSettingsBooleanElement)
		ifTrue: [ field margin: (BlInsets right: self horizontalInset - self trailingInset) ]
		ifFalse: [ field margin: (BlInsets top: self fieldVerticalAdjustment) ].

	aTrailing := BrFrame new
		hFitContent;
		vFitContent;
		margin: BlInsets empty;
		padding: BlInsets empty;
		addChild: field;
		yourself.
	aTrailing constraintsDo: [ :c |
		c linear vertical alignTop ].
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
		addChild: aLeading;
		addChild: aTrailing;
		yourself.

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
		margin: BlInsets empty;
		padding: (BlInsets right: self editorTextHorizontalInset).

	fieldColumn := BrFrame new
		hMatchParent;
		vFitContent;
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
		addChild: labelColumn;
		addChild: fieldColumn;
		yourself.
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
CFMaSettingsRowElement >> bottomInset [
	^ 6
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
CFMaSettingsRowElement >> topInset [
	^ 5
]


{ #category : 'private - metrics' }
CFMaSettingsRowElement >> wrappedColumnGap [
	^ 12
]

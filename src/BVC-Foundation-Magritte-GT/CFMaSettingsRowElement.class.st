Class {
	#name : 'CFMaSettingsRowElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'icon',
		'label',
		'comment',
		'field',
		'trailingActions',
		'actionsElement',
		'descriptionLine',
		'descriptionColumn',
		'bodyColumn',
		'contentLine',
		'editorColumn',
		'topLine',
		'wrapped',
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
	trailingActions := #().
	wrapped := false.
	cardTopInset := 0.
	cardBottomInset := 0.
	self
		hMatchParent;
		vFitContent;
		updatePadding;
		addAptitude: CFMaActiveSelectionAptitude new;
		addAptitude: CFMaSettingsRowAptitude new
]

{ #category : 'initialization' }
CFMaSettingsRowElement >> icon: anIcon label: aLabel comment: aComment field: aField trailingActions: aCollection [
	icon := anIcon.
	label := aLabel.
	comment := aComment.
	field := aField.
	trailingActions := aCollection ifNil: [ #() ].
	self
		updatePadding;
		buildRegions
]

{ #category : 'private - building' }
CFMaSettingsRowElement >> buildRegions [
	self removeChildren.
	wrapped := nil.

	actionsElement := BrHorizontalPane new
		hFitContent;
		vFitContent;
		margin: BlInsets empty;
		padding: BlInsets empty;
		layoutDo: [ :aLayout | aLayout cellSpacing: self actionSpacing ];
		yourself.
	trailingActions do: [ :anAction |
		anAction margin: BlInsets empty.
		actionsElement addChild: anAction ].

	descriptionLine := BrHorizontalPane new
		hFitContent;
		vFitContent;
		margin: BlInsets empty;
		padding: BlInsets empty;
		layout: BlLinearLayout horizontal alignTopLeft;
		yourself.
	label ifNotNil: [
		label
			margin: BlInsets empty;
			hFitContentLimited.
		descriptionLine addChild: label ].

	descriptionColumn := BrVerticalPane new
		hFitContent;
		vFitContent;
		margin: BlInsets empty;
		padding: BlInsets empty;
		yourself.
	descriptionLine childrenCount > 0 ifTrue: [ descriptionColumn addChild: descriptionLine ].

	editorColumn := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		padding: (BlInsets left: ((descriptionLine childrenCount > 0) ifTrue: [ self fieldGap ] ifFalse: [ 0 ]));
		layout: BlLinearLayout horizontal alignTopRight;
		yourself.
	editorColumn constraintsDo: [ :c |
		c linear weight: 1.
		c linear vertical alignTop ].

	field ifNotNil: [
		field
			margin: BlInsets empty;
			clipChildren: false.
		field constraints horizontal resizer isMatchParent
			ifTrue: [ field constraintsDo: [ :c | c linear weight: 1 ] ].
		editorColumn addChild: field ].
	actionsElement childrenCount > 0 ifTrue: [
		field ifNotNil: [ actionsElement margin: (BlInsets left: self actionsGap) ].
		editorColumn addChild: actionsElement ].

	topLine := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		padding: BlInsets empty;
		layout: BlLinearLayout horizontal alignTopLeft;
		yourself.
	descriptionColumn childrenCount > 0 ifTrue: [ topLine addChild: descriptionColumn ].
	field ifNotNil: [ topLine addChild: editorColumn ].

	bodyColumn := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		padding: BlInsets empty;
		addChild: topLine;
		yourself.
	bodyColumn constraintsDo: [ :c |
		c linear weight: 1.
		c linear vertical alignTop ].

	comment ifNotNil: [
		comment
			margin: (BlInsets top: self commentTopGap right: 0 bottom: 0 left: self commentLeftInset);
			hMatchParent;
			vFitContent.
		bodyColumn addChild: comment ].

	contentLine := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		padding: BlInsets empty;
		layout: BlLinearLayout horizontal alignTopLeft;
		yourself.
	icon ifNotNil: [
		icon margin: (BlInsets right: self iconGap).
		contentLine addChild: icon ].
	contentLine addChild: bodyColumn.
	self addChild: contentLine.

	self
		when: BlElementExtentChangedEvent
		do: [ :anEvent | self scheduleResponsiveArrangementUpdate ].
	field ifNotNil: [
		field
			when: BlElementExtentChangedEvent
			do: [ :anEvent | self scheduleResponsiveArrangementUpdate ] ].
	self scheduleResponsiveArrangementUpdate
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> scheduleResponsiveArrangementUpdate [
	self enqueueTask: (BlTaskAction new action: [ self updateResponsiveArrangement ])
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> updateResponsiveArrangement [
	| shouldWrap |
	shouldWrap := self shouldUseWrappedArrangement.
	shouldWrap = wrapped ifTrue: [ ^ self ].
	wrapped := shouldWrap.
	wrapped
		ifTrue: [ self useWrappedArrangement ]
		ifFalse: [ self useWideArrangement ]
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> shouldUseWrappedArrangement [
	| paragraphs availableWidth descriptionWidth editorWidth requiredWidth |
	field ifNil: [ ^ false ].
	availableWidth := bodyColumn extent x max: 0.
	availableWidth <= 0 ifTrue: [
		availableWidth := (self extent x - self padding width
			- (icon ifNil: [ 0 ] ifNotNil: [ icon measuredWidth + self iconGap ])) max: 0 ].
	availableWidth <= 0 ifTrue: [ ^ false ].

	paragraphs := field allChildrenBreadthFirstSelect: [ :each |
		each isKindOf: CFMaSettingsRightAlignedParagraphElement ].
	paragraphs size > 1 ifTrue: [ ^ true ].

	descriptionWidth := descriptionLine
		ifNil: [ 0 ]
		ifNotNil: [ descriptionLine measuredWidth ].
	editorWidth := paragraphs isEmpty
		ifTrue: [ field measuredWidth ]
		ifFalse: [ paragraphs first unwrappedWidth + field padding width ].
	actionsElement childrenCount > 0 ifTrue: [
		editorWidth := editorWidth + self actionsGap + actionsElement measuredWidth ].
	requiredWidth := descriptionWidth + self fieldGap + editorWidth.

	^ requiredWidth > availableWidth
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> useWideArrangement [
	comment ifNotNil: [
		comment hasParent ifTrue: [
			comment parent == bodyColumn ifFalse: [
				comment parent removeChild: comment.
				bodyColumn addChild: comment ] ].
		comment margin: (BlInsets top: self commentTopGap right: 0 bottom: 0 left: self commentLeftInset) ].
	descriptionColumn
		hFitContent;
		padding: BlInsets empty;
		constraintsDo: [ :c |
			c linear weight: 0.
			c linear vertical alignTop ].
	editorColumn
		padding: (BlInsets left: self fieldGap);
		constraintsDo: [ :c |
			c linear weight: 1.
			c linear vertical alignTop ].
	self requestLayout
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> useWrappedArrangement [
	comment ifNotNil: [
		comment hasParent ifTrue: [
			comment parent == descriptionColumn ifFalse: [
				comment parent removeChild: comment.
				descriptionColumn addChild: comment ] ].
		comment margin: (BlInsets top: self commentTopGap right: 0 bottom: 0 left: self commentLeftInset) ].
	descriptionColumn
		hMatchParent;
		padding: (BlInsets right: self fieldGap / 2);
		constraintsDo: [ :c |
			c linear weight: 1.
			c linear vertical alignTop ].
	editorColumn
		padding: (BlInsets left: self fieldGap / 2);
		constraintsDo: [ :c |
			c linear weight: 1.
			c linear vertical alignTop ].
	self requestLayout
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
		right: self horizontalInset)
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> iconGap [
	^ 10
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> fieldGap [
	^ 12
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> actionsGap [
	^ 4
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> actionSpacing [
	^ 4
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> commentTopGap [
	^ 1
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> commentLeftInset [
	^ 0.5
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> bottomInset [
	icon ifNil: [ ^ 6 ].
	comment ifNil: [ ^ 3 ].
	^ 5
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> horizontalInset [
	^ 8
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> topInset [
	^ icon
		ifNil: [ 5 ]
		ifNotNil: [ 4 ]
]

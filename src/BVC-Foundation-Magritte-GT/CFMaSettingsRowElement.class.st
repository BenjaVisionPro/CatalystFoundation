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
		'descriptionRegion',
		'editorRegion',
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
	cardTopInset := 0.
	cardBottomInset := 0.
	self
		hMatchParent;
		vFitContent;
		layout: CFMaSettingsRowLayout new;
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

	actionsElement := BrHorizontalPane new
		hFitContent;
		vMatchParent;
		clipChildren: false;
		margin: BlInsets empty;
		padding: (BlInsets top: 4);
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

	descriptionRegion := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		padding: BlInsets empty;
		yourself.
	descriptionLine childrenCount > 0 ifTrue: [ descriptionRegion addChild: descriptionLine ].
	comment ifNotNil: [
		comment
			margin: (BlInsets top: self commentTopGap right: 0 bottom: 0 left: self commentLeftInset);
			hMatchParent;
			vFitContent.
		descriptionRegion addChild: comment ].

	editorRegion := nil.
	(field notNil or: [ actionsElement childrenCount > 0 ]) ifTrue: [
		editorRegion := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			margin: BlInsets empty;
			padding: BlInsets empty;
			layout: BlLinearLayout horizontal alignTopRight;
			yourself.

		field ifNotNil: [
			field
				margin: BlInsets empty;
				clipChildren: false.
			field constraints horizontal resizer isMatchParent
				ifTrue: [ field constraintsDo: [ :c | c linear weight: 1 ] ].
			editorRegion addChild: field ].

		actionsElement childrenCount > 0 ifTrue: [
			actionsElement margin: (BlInsets
				left: (field ifNil: [ 0 ] ifNotNil: [ self actionsGap ])).
			editorRegion addChild: actionsElement ] ].

	icon ifNotNil: [
		icon margin: BlInsets empty.
		self addChild: icon ].
	self addChild: descriptionRegion.
	editorRegion ifNotNil: [ self addChild: editorRegion ]
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> iconElement [
	^ icon
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> descriptionLineElement [
	^ descriptionLine
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> descriptionRegionElement [
	^ descriptionRegion
]

{ #category : 'private - layout' }
CFMaSettingsRowElement >> editorRegionElement [
	^ editorRegion
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
		top: self topInset
		left: self horizontalInset
		bottom: self bottomInset
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
	icon ifNil: [ ^ 6 + cardBottomInset ].
	comment ifNil: [ ^ 3 + cardBottomInset ].
	^ 5 + cardBottomInset
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> horizontalInset [
	^ 8
]

{ #category : 'private - metrics' }
CFMaSettingsRowElement >> topInset [
	^ (icon
		ifNil: [ 5 ]
		ifNotNil: [ 4 ]) + cardTopInset
]

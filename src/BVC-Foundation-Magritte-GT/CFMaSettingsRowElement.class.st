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
		vFitContent;
		margin: BlInsets empty;
		padding: BlInsets empty;
		layoutDo: [ :aLayout | aLayout cellSpacing: self actionSpacing ];
		yourself.
	trailingActions do: [ :anAction |
		anAction margin: BlInsets empty.
		actionsElement addChild: anAction ].

	label ifNotNil: [ label margin: BlInsets empty ].
	comment ifNotNil: [ comment margin: BlInsets empty ].
	field ifNotNil: [
		field
			margin: BlInsets empty;
			clipChildren: false ].

	icon ifNotNil: [ self addChild: icon ].
	label ifNotNil: [ self addChild: label ].
	comment ifNotNil: [ self addChild: comment ].
	field ifNotNil: [ self addChild: field ].
	self addChild: actionsElement
]

{ #category : 'testing - layout' }
CFMaSettingsRowElement >> hasDescription [
	^ label notNil or: [ comment notNil ]
]

{ #category : 'accessing - layout' }
CFMaSettingsRowElement >> iconElement [
	^ icon
]

{ #category : 'accessing - layout' }
CFMaSettingsRowElement >> labelElement [
	^ label
]

{ #category : 'accessing - layout' }
CFMaSettingsRowElement >> commentElement [
	^ comment
]

{ #category : 'accessing - layout' }
CFMaSettingsRowElement >> editorElement [
	^ field
]

{ #category : 'accessing - layout' }
CFMaSettingsRowElement >> actionsElement [
	^ actionsElement
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

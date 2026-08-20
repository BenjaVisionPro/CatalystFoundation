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
		'primaryLine',
		'flexibleSpace',
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

	primaryLine := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		padding: BlInsets empty;
		layout: BlLinearLayout horizontal alignTopLeft;
		yourself.

	label ifNotNil: [
		label
			margin: BlInsets empty;
			hFitContentLimited ].
	comment ifNotNil: [ comment margin: BlInsets empty ].
	field ifNotNil: [
		field
			margin: BlInsets empty;
			clipChildren: false ].

	icon ifNotNil: [
		icon margin: (BlInsets right: self iconGap).
		primaryLine addChild: icon ].
	label ifNotNil: [ primaryLine addChild: label ].
	field ifNotNil: [
		(label notNil or: [ comment notNil ]) ifTrue: [
			field constraints horizontal resizer isMatchParent
				ifTrue: [ field margin: (BlInsets left: self fieldGap) ]
				ifFalse: [
					flexibleSpace := BlElement new
						hMatchParent;
						vExact: 0;
						margin: (BlInsets left: self fieldGap);
						constraintsDo: [ :c | c linear weight: 1 ];
						yourself.
					primaryLine addChild: flexibleSpace ] ].
		primaryLine addChild: field ].
	actionsElement childrenCount > 0 ifTrue: [
		field ifNotNil: [ actionsElement margin: (BlInsets left: self actionsGap) ].
		primaryLine addChild: actionsElement ].

	self addChild: primaryLine.
	comment ifNotNil: [ self addChild: comment ]
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

{ #category : 'accessing - layout' }
CFMaSettingsRowElement >> primaryLineElement [
	^ primaryLine
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

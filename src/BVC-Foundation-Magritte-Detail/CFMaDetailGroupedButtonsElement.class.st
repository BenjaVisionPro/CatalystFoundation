"I edit one MASingleOptionDescription as a mutually-exclusive compact group of buttons.

I reuse Brick toggle-group semantics for exclusivity. The option description owns the values and display strings. When the description provides #blocOptionIconStencil I render icon buttons; otherwise I render text buttons. I do not own a model or shadow value: the presentation supplies the current value and writes changes through its memento."

Class {
	#name : 'CFMaDetailGroupedButtonsElement',
	#superclass : 'BrToggleGroup',
	#instVars : [
		'options',
		'displayBlock',
		'iconBlock',
		'valueChangedBlock',
		'togglesByOption',
		'updatingValue'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailGroupedButtonsElement >> initialize [
	super initialize.
	options := #().
	displayBlock := [ :anOption | anOption asString ].
	iconBlock := nil.
	valueChangedBlock := [ :anOption | ].
	togglesByOption := Dictionary new.
	updatingValue := false.
	self
		hFitContent;
		vExact: 28;
		layout: (BlLinearLayout horizontal cellSpacing: 0);
		padding: (BlInsets all: 2);
		margin: BlInsets empty;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 9);
		background: Color transparent;
		border: BlBorder empty;
		addAptitude: (BrLazyStyleCommonAptitude new
			default: [ :aStyle |
				aStyle background: self theme interaction controlBackgroundTint ]);
		yourself
]

{ #category : 'configuration' }
CFMaDetailGroupedButtonsElement >> options: aCollection display: aDisplayBlock icon: anIconBlock [
	options := aCollection asArray.
	displayBlock := aDisplayBlock.
	iconBlock := anIconBlock.
	self rebuildButtons
]

{ #category : 'callbacks' }
CFMaDetailGroupedButtonsElement >> valueChangedBlock: aBlock [
	valueChangedBlock := aBlock
]

{ #category : 'accessing' }
CFMaDetailGroupedButtonsElement >> options [
	^ options
]

{ #category : 'accessing' }
CFMaDetailGroupedButtonsElement >> value: anOption [
	| aToggle |
	aToggle := togglesByOption
		at: anOption
		ifAbsent: [ self error: 'The grouped-buttons value must be one of its configured options' ].
	updatingValue := true.
	[ aToggle activate ] ensure: [ updatingValue := false ]
]

{ #category : 'accessing - testing' }
CFMaDetailGroupedButtonsElement >> toggleForOption: anOption [
	^ togglesByOption at: anOption
]

{ #category : 'private - building' }
CFMaDetailGroupedButtonsElement >> rebuildButtons [
	self removeToggles.
	togglesByOption removeAll.
	options do: [ :anOption |
		| aToggle |
		aToggle := iconBlock
			ifNil: [ self newTextToggleFor: anOption ]
			ifNotNil: [ self newIconToggleFor: anOption ].
		togglesByOption at: anOption put: aToggle.
		self addToggle: aToggle ]
]

{ #category : 'private - building' }
CFMaDetailGroupedButtonsElement >> newIconToggleFor: anOption [
	| anIcon aToggle |
	anIcon := iconBlock value: anOption.
	anIcon size: 16 @ 16.
	aToggle := BrToggle new
		aptitude: BrGlamorousButtonIconAptitude new
			+ BrGlamorousToggleLayoutAptitude new
			+ self toggleStyle;
		icon: anIcon;
		hExact: 34;
		vExact: 24;
		padding: BlInsets empty;
		addAptitude: (BrGlamorousWithExplicitTooltipAptitude
			text: (displayBlock value: anOption) asString);
		yourself.
	aToggle addAptitude: (CFMaDetailLazyToggleAptitude new
		@ anIcon;
		default: [ :aState |
			aState do: [ anIcon color: aToggle theme controls inactiveIconForeground ] ];
		activated: [ :aState |
			aState do: [ anIcon color: Color white ] ]).
	self installValueChangeOn: aToggle option: anOption.
	^ aToggle
]

{ #category : 'private - building' }
CFMaDetailGroupedButtonsElement >> newTextToggleFor: anOption [
	| aToggle |
	aToggle := BrToggle new
		aptitude: BrGlamorousTextLabelAptitude new
			+ BrGlamorousToggleLayoutAptitude new
			+ self toggleStyle;
		label: (displayBlock value: anOption) asString;
		vExact: 24;
		padding: (BlInsets left: 12 right: 12);
		yourself.
	aToggle addAptitude: (CFMaDetailLazyToggleAptitude new
		default: [ :aState |
			aState do: [
				aToggle label: ((displayBlock value: anOption) asString asRopedText
					foreground: aToggle theme typography primaryForeground) ] ];
		activated: [ :aState |
			aState do: [
				aToggle label: ((displayBlock value: anOption) asString asRopedText
					foreground: Color white) ] ]).
	self installValueChangeOn: aToggle option: anOption.
	^ aToggle
]

{ #category : 'private - interaction' }
CFMaDetailGroupedButtonsElement >> installValueChangeOn: aToggle option: anOption [
	aToggle
		when: BrToggleActivatedEvent
		do: [ :anEvent |
			updatingValue ifFalse: [ valueChangedBlock value: anOption ] ]
]

{ #category : 'private - appearance' }
CFMaDetailGroupedButtonsElement >> toggleStyle [
	^ CFMaDetailLazyToggleAptitude new
		default: [ :aState |
			aState
				background: Color transparent;
				geometry: (BlRoundedRectangleGeometry cornerRadius: 7) ];
		hovered: [ :aState |
			aState background: self theme interaction subtleBackgroundTint ];
		activated: [ :aState |
			aState background: self theme item selectedColor ];
		yourself
]

{ #category : 'layout' }
CFMaDetailGroupedButtonsElement >> supportsBaseline [
	^ true
]

{ #category : 'layout' }
CFMaDetailGroupedButtonsElement >> baselineOffset [
	^ 18
]

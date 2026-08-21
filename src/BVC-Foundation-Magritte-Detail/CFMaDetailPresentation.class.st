Class {
	#name : 'CFMaDetailPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'groupConfigurations'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPresentation >> initialize [
	super initialize.
	groupConfigurations := Dictionary new
]

{ #category : 'configuration' }
CFMaDetailPresentation >> group: aGroup configure: aBlock [
	| aConfiguration |
	aConfiguration := self groupConfigurationFor: aGroup.
	aBlock cull: aConfiguration.
	^ self
]

{ #category : 'configuration' }
CFMaDetailPresentation >> groupConfigurationFor: aGroup [
	^ groupConfigurations
		at: aGroup
		ifAbsentPut: [ CFMaDetailGroupConfiguration new ]
]

{ #category : 'configuration' }
CFMaDetailPresentation >> groupConfigurationAt: aGroup ifAbsent: aBlock [
	^ groupConfigurations at: aGroup ifAbsent: aBlock
]

{ #category : 'private - composition' }
CFMaDetailPresentation >> addLabel: aLabel field: aFieldElement for: aDescription [
	| aSupportingElement aRow |
	aSupportingElement := aDescription hasComment
		ifTrue: [ self supportingElementFor: aDescription ]
		ifFalse: [ nil ].
	aRow := self
		newRowLeading: nil
		description: aLabel
		supporting: aSupportingElement
		content: aFieldElement
		accessories: #().
	(self containerForDescription: aDescription) addChild: aRow
]

{ #category : 'private - composition' }
CFMaDetailPresentation >> supportingElementFor: aDescription [
	^ BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithoutSelection;
		focusability: BlFocusability none;
		text: (aDescription comment asRopedText
			foreground: (Color black alpha: 0.52);
			fontSize: 11);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		background: Color transparent;
		border: BlBorder empty;
		padding: BlInsets empty;
		margin: BlInsets empty;
		yourself
]

{ #category : 'private - composition' }
CFMaDetailPresentation >> newRowLeading: aLeadingElement description: aDescriptionElement supporting: aSupportingElement content: aContentElement accessories: accessoryElements [
	| aRow |
	aRow := BlElement new
		layout: CFMaDetailRowLayout new;
		background: Color transparent;
		border: BlBorder empty;
		padding: (BlInsets top: 6 right: 8 bottom: 6 left: 8);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		yourself.

	aLeadingElement ifNotNil: [
		aLeadingElement margin: BlInsets empty.
		aLeadingElement constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beLeading ].
		aRow addChild: aLeadingElement ].
	aDescriptionElement ifNotNil: [
		aDescriptionElement margin: BlInsets empty.
		aDescriptionElement constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beDescription ].
		aRow addChild: aDescriptionElement ].
	aSupportingElement ifNotNil: [
		aSupportingElement margin: BlInsets empty.
		aSupportingElement constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beSupporting ].
		aRow addChild: aSupportingElement ].
	aContentElement ifNotNil: [
		aContentElement
			margin: BlInsets empty;
			clipChildren: false.
		aContentElement constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beContent ].
		aRow addChild: aContentElement ].
	accessoryElements do: [ :anAccessory |
		anAccessory margin: BlInsets empty.
		anAccessory constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beAccessory ].
		aRow addChild: anAccessory ].
	^ aRow
]

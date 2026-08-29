Class {
	#name : 'CFMaDetailAddIconElement',
	#superclass : 'BlElement',
	#instVars : [
		'icon',
		'hovered'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'instance creation' }
CFMaDetailAddIconElement class >> size: anExtent [
	^ self new
		iconSize: anExtent;
		yourself
]

{ #category : 'initialization' }
CFMaDetailAddIconElement >> initialize [
	super initialize.
	hovered := false.
	icon := FontAwesomeIcons defaultStyle icon: #circlePlus.
	self
		layout: BlFrameLayout new;
		background: Color transparent;
		border: BlBorder empty;
		addChild: icon.
	icon constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	self updateAppearance
]

{ #category : 'accessing' }
CFMaDetailAddIconElement >> iconSize: anExtent [
	icon size: anExtent.
	self size: anExtent
]

{ #category : 'appearance' }
CFMaDetailAddIconElement >> hovered: aBoolean [
	hovered := aBoolean.
	self updateAppearance
]

{ #category : 'lifecycle' }
CFMaDetailAddIconElement >> onThemeChanged [
	super onThemeChanged.
	icon ifNotNil: [ self updateAppearance ]
]

{ #category : 'private - appearance' }
CFMaDetailAddIconElement >> updateAppearance [
	icon color: (hovered
		ifTrue: [ self theme appearanceState themeColour ]
		ifFalse: [ self theme typography secondaryForeground ])
]

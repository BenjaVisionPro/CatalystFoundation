Class {
	#name : 'CFMaDetailTagElement',
	#superclass : 'CFEditableLabel',
	#instVars : [
		'value',
		'selectedBlock',
		'tagAptitude'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailTagElement >> initialize [
	super initialize.
	tagAptitude := (CFMaDetailTagAptitude
		background: (Color black alpha: 0.06)
		focused: (Color r: 52 g: 120 b: 247 range: 255))
		glamorousRegularFont;
		glamorousRegularSmallSize.
	self
		aptitude: tagAptitude;
		fitContent;
		padding: (BlInsets top: 2 right: 8 bottom: 2 left: 8);
		margin: (BlInsets top: 2 right: 4 bottom: 2 left: 0);
		border: BlBorder empty;
		constraintsDo: [ :c | c flow vertical alignCenter ];
		when: BlClickEvent do: [ :anEvent |
			selectedBlock ifNotNil: [ selectedBlock cull: self ] ].
]

{ #category : 'accessing' }
CFMaDetailTagElement >> selectedBlock: aBlock [
	selectedBlock := aBlock
]

{ #category : 'accessing' }
CFMaDetailTagElement >> value [
	^ value
]

{ #category : 'accessing' }
CFMaDetailTagElement >> value: anObject [
	value := anObject
]

{ #category : 'selection' }
CFMaDetailTagElement >> beSelected [
	self requestFocus
]

{ #category : 'selection' }
CFMaDetailTagElement >> beUnselected [
	tagAptitude applyTheme: self theme
]


{ #category : #'theme - applying' }
CFMaDetailTagElement >> onThemeChanged [
	super onThemeChanged.
	tagAptitude ifNotNil: [ tagAptitude applyTheme: self theme ]
]


{ #category : #lifecycle }
CFMaDetailTagElement >> onAddedToParent [
	super onAddedToParent.
	tagAptitude ifNotNil: [ tagAptitude applyTheme: self theme ]
]

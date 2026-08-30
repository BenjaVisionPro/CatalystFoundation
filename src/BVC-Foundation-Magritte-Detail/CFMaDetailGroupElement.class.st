Class {
	#name : 'CFMaDetailGroupElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'composition',
		'currentCard',
		'groups',
		'configuration'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'adding' }
CFMaDetailGroupElement >> addContent: anElement [
	self currentCard addChild: anElement.
	^ anElement
]

{ #category : 'adding' }
CFMaDetailGroupElement >> addNestedPresentationElement: anElement [
	currentCard := nil.
	self addCompositionElement: anElement.
	^ anElement
]

{ #category : 'private - composition' }
CFMaDetailGroupElement >> addCompositionElement: anElement [
	| aMargin |
	aMargin := anElement margin.
	anElement margin: (BlInsets
		top: (composition children isEmpty ifTrue: [ aMargin top ] ifFalse: [ self groupSpacing ])
		right: aMargin right
		bottom: aMargin bottom
		left: aMargin left).
	composition addChild: anElement.
	^ anElement
]

{ #category : 'adding' }
CFMaDetailGroupElement >> addGroup: aGroup label: aLabel [
	currentCard := nil.
	self ensureGroups.
	(configuration presentation isKindOf: CFMaDetailTabsConfiguration)
		ifTrue: [
			aGroup margin: (BlInsets top: self groupSpacing).
			^ groups addTab: (BrTab new
				aptitude: BrGlamorousTabAptitude new;
				label: aLabel asString;
				stencil: [ aGroup ];
				yourself) ].
	(configuration presentation isKindOf: CFMaDetailButtonBarConfiguration)
		ifTrue: [ ^ groups addGroup: aGroup label: aLabel ].
	groups addChild: aGroup.
	self updateGroupSpacing
]

{ #category : 'accessing' }
CFMaDetailGroupElement >> configuration: aConfiguration [
	configuration := aConfiguration.
	currentCard ifNotNil: [
		currentCard reservedAccessorySlots: aConfiguration reservedAccessorySlots ]
]

{ #category : 'private - composition' }
CFMaDetailGroupElement >> currentCard [
	currentCard ifNotNil: [ ^ currentCard ].
	currentCard := CFMaDetailGroupCardElement new
		margin: (BlInsets left: 6 right: 6);
		reservedAccessorySlots: configuration reservedAccessorySlots;
		yourself.
	self addCompositionElement: currentCard.
	^ currentCard
]

{ #category : 'private' }
CFMaDetailGroupElement >> ensureGroups [
	groups ifNotNil: [ ^ groups ].
	groups := (configuration presentation isKindOf: CFMaDetailTabsConfiguration)
		ifTrue: [
			BrTabGroup new
				hMatchParent;
				vFitContent;
				aptitude: BrGlamorousTabGroupAptitude new;
				yourself ]
		ifFalse: [
			(configuration presentation isKindOf: CFMaDetailButtonBarConfiguration)
				ifTrue: [ CFMaDetailButtonBarElement new configuration: configuration presentation; yourself ]
				ifFalse: [
					BrVerticalPane new
						hMatchParent;
						vFitContent;
						cellSpacing: 0;
						margin: BlInsets empty;
						yourself ] ].
	self addCompositionElement: groups.
	^ groups
]

{ #category : 'private - layout' }
CFMaDetailGroupElement >> updateGroupSpacing [
	groups ifNil: [ ^ self ].
	(configuration presentation isKindOf: CFMaDetailTabsConfiguration) ifTrue: [ ^ self ].
	(configuration presentation isKindOf: CFMaDetailButtonBarConfiguration) ifTrue: [ ^ self ].
	groups children
		withIndexDo: [ :aGroup :anIndex |
			| aMargin |
			aMargin := aGroup margin.
			aGroup margin: (BlInsets
				top: (anIndex = 1 ifTrue: [ 0 ] ifFalse: [ self groupSpacing ])
				right: aMargin right
				bottom: aMargin bottom
				left: aMargin left) ]
]

{ #category : 'geometry' }
CFMaDetailGroupElement >> groupSpacing [
	^ 10
]

{ #category : 'accessing' }
CFMaDetailGroupElement >> group: aGroup [
	aGroup ifNil: [ ^ self ].
	configuration labelVisible ifFalse: [ ^ self ].
	self addChildFirst: (BrLabel new
		text: aGroup asString;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (self theme typography primaryForeground);
			fontSize: (self theme typography groupHeadingFontSize);
			bold);
		fitContent;
		margin: (BlInsets top: 25 right: 14 bottom: 7 left: 14);
		yourself)
]

{ #category : 'initialization' }
CFMaDetailGroupElement >> initialize [
	super initialize.
	currentCard := nil.
	groups := nil.
	composition := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		cellSpacing: 0;
		yourself.
	self
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		cellSpacing: 0;
		addChild: composition
]

{ #category : 'accessing' }
CFMaDetailGroupElement >> rows [
	^ self currentCard
]

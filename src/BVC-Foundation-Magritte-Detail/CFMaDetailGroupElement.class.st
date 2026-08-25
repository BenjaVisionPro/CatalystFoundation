Class {
	#name : 'CFMaDetailGroupElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'card',
		'groups',
		'configuration'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'adding' }
CFMaDetailGroupElement >> addGroup: aGroup label: aLabel [
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
	card reservedAccessorySlots: aConfiguration reservedAccessorySlots
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
	self addChild: groups.
	^ groups
]

{ #category : 'private - layout' }
CFMaDetailGroupElement >> updateGroupSpacing [
	groups ifNil: [ ^ self ].
	groups children
		withIndexDo: [ :aGroup :anIndex |
			| aMargin |
			aMargin := aGroup margin.
			aGroup margin: (BlInsets
				top: ((anIndex = 1 and: [ card rowCount = 0 ])
					ifTrue: [ 0 ]
					ifFalse: [ self groupSpacing ])
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
	self addChildFirst: (BrLabel new
		text: aGroup asString;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: CFMaDetailColours primaryForeground;
			fontSize: 14;
			bold);
		fitContent;
		margin: (BlInsets top: 25 right: 14 bottom: 7 left: 14);
		yourself)
]

{ #category : 'initialization' }
CFMaDetailGroupElement >> initialize [
	super initialize.
	card := CFMaDetailGroupCardElement new
		visibility: BlVisibility gone;
		margin: (BlInsets left: 6 right: 6);
		yourself.
	self
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		cellSpacing: 0;
		addChild: card
]

{ #category : 'accessing' }
CFMaDetailGroupElement >> rows [
	card visibility: BlVisibility visible.
	groups ifNotNil: [ self updateGroupSpacing ].
	^ card
]

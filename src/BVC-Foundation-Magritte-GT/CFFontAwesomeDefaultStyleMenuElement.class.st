Class {
	#name : 'CFFontAwesomeDefaultStyleMenuElement',
	#superclass : 'GtAbstractCoderContextMenuContent',
	#instVars : [
		'iconLibraryClass',
		'menuModel'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'instance creation' }
CFFontAwesomeDefaultStyleMenuElement class >> menuActionIconFor: anIconLibraryClass [
	^ [
		| icon |
		icon := (anIconLibraryClass style: 'brands') icon: #fontAwesomeFlag.
		BlElement new
			size: 16 @ 16;
			layout: BlFrameLayout new;
			addChild: (icon asScalableElementSized: (icon extentForHeight: 14)) ]
		asStencil
]

{ #category : 'instance creation' }
CFFontAwesomeDefaultStyleMenuElement class >> menuContentFor: anIconLibraryClass button: aButton menuModel: anExplicitMenu [
	| aMenuElement |
	aMenuElement := self new
		iconLibraryClass: anIconLibraryClass;
		menuModel: anExplicitMenu;
		initializeItems;
		yourself.

	^ aMenuElement
		background: aButton theme default contentBackground;
		addAptitude: (BrGlamorousPopoverPinnableAptitude new
				withAllPinActions;
				menuModel: anExplicitMenu);
		yourself
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement class >> menuItemGroup [
	^ BrMenuItemGroupConfiguration new
		name: 'Font Awesome';
		priority: 44;
		yourself
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement class >> previewSelectorForStyleNamed: aStyleName [
	aStyleName = 'brands' ifTrue: [ ^ #fontAwesomeFlag ].
	^ #star
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement class >> styleLabelFor: aStyleName [
	^ aStyleName asString capitalized
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement class >> shouldShowActionFor: anIconLibraryClass [
	^ anIconLibraryClass styleName isNil
		and: [ anIconLibraryClass availableStyles size > 1 ]
]

{ #category : 'accessing' }
CFFontAwesomeDefaultStyleMenuElement >> iconLibraryClass: aClass [
	iconLibraryClass := aClass
]

{ #category : 'initialization' }
CFFontAwesomeDefaultStyleMenuElement >> initializeItems [
	self items: iconLibraryClass availableStyles
]

{ #category : 'accessing' }
CFFontAwesomeDefaultStyleMenuElement >> itemPadding [
	^ BlInsets top: 4 bottom: 4 left: 2 right: 2
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement >> menuItemStencil [
	^ [ :aStyleName :aRowIndex |
		| anElement |
		anElement := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			alignCenter;
			addAptitude: self selectionAptitude;
			padding: self itemPadding;
			when: BlClickEvent
				do: [ :anEvent |
					anEvent consumed: true.
					self selectStyleNamed: aStyleName ].

		anElement
			addChild: (self previewIconElementForStyleNamed: aStyleName);
			addChild: (self itemLabelFor: (self class styleLabelFor: aStyleName)).

		anElement ]
]

{ #category : 'accessing' }
CFFontAwesomeDefaultStyleMenuElement >> menuModel: aMenuModel [
	menuModel := aMenuModel
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement >> previewIconElementForStyleNamed: aStyleName [
	| aSelector anIcon |
	aSelector := self class previewSelectorForStyleNamed: aStyleName.
	aSelector ifNil: [ ^ BlElement new size: 16 @ 16 ].

	anIcon := [
		(iconLibraryClass style: aStyleName) icon: aSelector ]
			on: Error
			do: [ :anError | ^ BlElement new size: 16 @ 16 ].
	^ (anIcon asScalableElementSized: (anIcon extentForHeight: 16))
		margin: (BlInsets right: 8);
		yourself
]

{ #category : 'actions' }
CFFontAwesomeDefaultStyleMenuElement >> selectStyleNamed: aStyleName [
	iconLibraryClass defaultStyleName = aStyleName ifFalse: [
		iconLibraryClass defaultStyleName: aStyleName ].
	menuModel
		ifNil: [ self fireEvent: BrContextMenuHideWish new ]
		ifNotNil: [ menuModel hideAll ]
]

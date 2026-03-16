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
	| icon |
	icon := (anIconLibraryClass style: 'brands') icon: #fontAwesomeFlag.
	^ icon height: 16
]

{ #category : 'instance creation' }
CFFontAwesomeDefaultStyleMenuElement class >> menuContentFor: anIconLibraryClass button: aButton menuModel: anExplicitMenu [
	| aMenuElement |
	aMenuElement := self new
		iconLibraryClass: anIconLibraryClass;
		menuModel: anExplicitMenu;
		initializeItems;
		yourself.

	^ BrFrame new
		addChild: aMenuElement;
		background: aButton theme default contentBackground;
		hExact: 240;
		vFitContentLimited;
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
CFFontAwesomeDefaultStyleMenuElement class >> previewSelectorForStyleNamed: aStyleName in: anIconLibraryClass [
	| aStyleClass someSelectors preferredSelectors |
	aStyleClass := anIconLibraryClass style: aStyleName.
	someSelectors := aStyleClass availableIcons collect: #key.
	preferredSelectors := aStyleName = 'brands'
		ifTrue: [ #(fontAwesomeFlag fontAwesomeLogoFull) ]
		ifFalse: [ #(star heart bookmark circle square flag user) ].

	^ preferredSelectors
		detect: [ :eachSelector | someSelectors includes: eachSelector ]
		ifNone: [ someSelectors ifEmpty: [ nil ] ifNotEmpty: [ someSelectors first ] ]
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
	aSelector := self class
		previewSelectorForStyleNamed: aStyleName
		in: iconLibraryClass.
	aSelector ifNil: [ ^ BlElement new size: 16 @ 16 ].

	anIcon := (iconLibraryClass style: aStyleName) icon: aSelector.
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

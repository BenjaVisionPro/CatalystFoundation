Class {
	#name : 'CFFontAwesomeDefaultStyleMenuElement',
	#superclass : 'BrGlamorousSimpleContextMenuContent',
	#instVars : [
		'iconLibraryClass',
		'dropdown',
		'toolbarElement',
		'behaviorCoderElement'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'instance creation' }
CFFontAwesomeDefaultStyleMenuElement class >> configureAction: anAction for: anIconLibraryClass [
	(self shouldShowActionFor: anIconLibraryClass)
		ifFalse: [ ^ anAction noAction ].

	^ anAction dropdown
		tooltip: 'Choose the default Font Awesome style';
		label: anIconLibraryClass defaultStyleName;
		icon: (self iconStencilFor: anIconLibraryClass);
		priority: 5;
		content: [ :aDropdown :aToolbarElement |
			self new
				iconLibraryClass: anIconLibraryClass;
				dropdown: aDropdown;
				toolbarElement: aToolbarElement;
				initializeItems;
				yourself ]
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement class >> iconStencilFor: anIconLibraryClass [
	| icon |
	icon := (anIconLibraryClass style: 'brands') icon: #fontAwesomeFlag.
	^ [ icon asScalableElementSized: (icon extentForHeight: 16) ] asStencil
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement class >> shouldShowActionFor: anIconLibraryClass [
	^ anIconLibraryClass styleName isNil
		and: [ anIconLibraryClass availableStyles size > 1 ]
]

{ #category : 'accessing' }
CFFontAwesomeDefaultStyleMenuElement >> dropdown: anElement [
	dropdown := anElement
]

{ #category : 'accessing' }
CFFontAwesomeDefaultStyleMenuElement >> iconLibraryClass: aClass [
	iconLibraryClass := aClass
]

{ #category : 'initialization' }
CFFontAwesomeDefaultStyleMenuElement >> initializeItems [
	self items: self menuItems
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement >> menuItems [
	^ iconLibraryClass availableStyles collect: [ :aStyleName |
		(self menuLabelForStyleNamed: aStyleName)
			-> [ :anAnchor | self selectStyleNamed: aStyleName ] ]
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement >> menuLabelForStyleNamed: aStyleName [
	^ aStyleName = iconLibraryClass defaultStyleName
		ifTrue: [ '* ', aStyleName ]
		ifFalse: [ '  ', aStyleName ]
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement >> refreshSelectedClassView [
	| aTabGroup |
	behaviorCoderElement ifNil: [ ^ self ].
	aTabGroup := behaviorCoderElement
		allChildrenBreadthFirstDetect: [ :anElement | anElement isKindOf: BrTabGroup ]
		ifFound: [ :anElement | anElement ]
		ifNone: [ ^ self ].
	aTabGroup viewModel
		selectedTabDo: [ :aTabModel | aTabModel widget viewContentElement phlow update ]
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement >> refreshToolbarAndClassView [
	toolbarElement ifNil: [ ^ self ].
	toolbarElement enqueueTask: (BlTaskAction new
		action: [
			self refreshToolbarButtons.
			self refreshSelectedClassView ])
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement >> refreshToolbarButtons [
	| aBrToolbar |
	aBrToolbar := toolbarElement toolbarElement.
	aBrToolbar numberOfItems
		timesRepeat: [ aBrToolbar removeItemAt: 1 ].
	toolbarElement addCustomButtons
]

{ #category : 'actions' }
CFFontAwesomeDefaultStyleMenuElement >> selectStyleNamed: aStyleName [
	iconLibraryClass defaultStyleName = aStyleName ifFalse: [
		iconLibraryClass defaultStyleName: aStyleName ].
	dropdown fireEvent: BrDropdownHideWish new.
	self fireEvent: BrContextMenuHideWish new.
	self refreshToolbarAndClassView
]

{ #category : 'accessing' }
CFFontAwesomeDefaultStyleMenuElement >> toolbarElement: anElement [
	toolbarElement := anElement.
	behaviorCoderElement := anElement
		allParentsDetect: [ :eachElement | eachElement isKindOf: GtPharoBehaviorCoderElement ]
		ifFound: [ :eachElement | eachElement ]
		ifNone: [ nil ]
]

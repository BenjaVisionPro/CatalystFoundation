Class {
	#name : 'CFFontAwesomeDefaultStyleMenuElement',
	#superclass : 'BrGlamorousSimpleContextMenuContent',
	#instVars : [
		'iconLibraryClass',
		'dropdown',
		'target'
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
		content: [ :aDropdown :aTarget |
			self new
				iconLibraryClass: anIconLibraryClass;
				dropdown: aDropdown;
				target: aTarget;
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
CFFontAwesomeDefaultStyleMenuElement >> refreshInCoderToolbar: aToolbarElement [
	| aBehaviorCoderElement |
	aBehaviorCoderElement := aToolbarElement
		allParentsDetect: [ :anElement | anElement isKindOf: GtPharoBehaviorCoderElement ]
		ifFound: [ :anElement | anElement ]
		ifNone: [ ^ self ].
	self refreshSelectedClassViewIn: aBehaviorCoderElement
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement >> refreshInTabFor: anElement [
	anElement
		allParentsDetect: [ :aParent | aParent isKindOf: BrTab ]
		ifFound: [ :aTab | aTab viewContentElement phlow update ]
		ifNone: [ ]
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement >> refreshSelectedClassViewIn: aBehaviorCoderElement [
	| aTabGroup |
	aTabGroup := aBehaviorCoderElement
		allChildrenBreadthFirstDetect: [ :anElement | anElement isKindOf: BrTabGroup ]
		ifFound: [ :anElement | anElement ]
		ifNone: [ ^ self ].
	aTabGroup viewModel
		selectedTabDo: [ :aTabModel | aTabModel widget viewContentElement phlow update ]
]

{ #category : 'private' }
CFFontAwesomeDefaultStyleMenuElement >> refreshTarget [
	(target isKindOf: GtCoderToolbarElement)
		ifTrue: [ ^ self refreshInCoderToolbar: target ].
	self refreshInTabFor: target
]

{ #category : 'actions' }
CFFontAwesomeDefaultStyleMenuElement >> selectStyleNamed: aStyleName [
	iconLibraryClass defaultStyleName = aStyleName ifFalse: [
		iconLibraryClass defaultStyleName: aStyleName ].
	dropdown fireEvent: BrDropdownHideWish new.
	self refreshTarget
]

{ #category : 'accessing' }
CFFontAwesomeDefaultStyleMenuElement >> target: anElement [
	target := anElement
]

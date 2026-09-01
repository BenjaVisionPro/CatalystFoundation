Class {
	#name : 'CFMaAddItemViewModel',
	#superclass : 'GtMagritteAddItemViewModel',
	#instVars : [
		'classStencil'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'private - adding' }
CFMaAddItemViewModel >> addItemForClass: aClass from: anElement [
	| aNewItem |
	self memento ifNil: [ ^ self ].
	self description ifNil: [ ^ self ].

	aNewItem := self createItemForClass: aClass.
	aNewItem ifNil: [ ^ self ].

	CFMaBuilderUtility
		addToManyObject: aNewItem
		memento: self memento
		using: self description
		element: anElement
]

{ #category : 'converting' }
CFMaAddItemViewModel >> asElement [
	self shouldDisableAddButton
		ifTrue: [ ^ self newDisabledAddButton ].

	self shouldShowNewItemClassChoiceMenu
		ifTrue: [ ^ self newClassChoiceAddElement ].

	^ self newImmediateAddButton
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> createItemForClass: aClass [
	self classStencil ifNotNil: [ :aClassStencil |
		^ aClassStencil
			itemClass: aClass;
			memento: self memento;
			description: self description;
			build ].

	self stencil ifNil: [ ^ nil ].
	^ self stencil create
]

{ #category : 'private - testing' }
CFMaAddItemViewModel >> hasMultipleNewItemClasses [
	self description ifNil: [ ^ false ].
	^ self newItemClasses size > 1
]

{ #category : 'private - testing' }
CFMaAddItemViewModel >> hasNewItemClasses [
	^ self newItemClasses notEmpty
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newClassChoiceAddElement [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude
			+ ((BrGlamorousWithExplicitDropdownAptitude
				handle: [ self newClassChoiceHandle ]
				menu: [ self newClassChoiceMenu ])
					withGainFocusOnShow;
					yourself);
		icon: (FontAwesomeIcons defaultStyle icon: #plus);
		label: 'Add item';
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newClassChoiceHandle [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude - BrGlamorousButtonExteriorAptitude;
		icon: (FontAwesomeIcons defaultStyle icon: #plus);
		label: 'Add item';
		yourself
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newClassChoiceMenu [
	| aMenu |
	aMenu := BrMenuItems new.
	aMenu beListElementType.
	self newItemClasses do: [ :aClass |
		aMenu addItem: (self newMenuItemForClass: aClass) ].
	^ aMenu
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newDisabledAddButton [
	^ self newImmediateAddButton
		disable;
		yourself
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newImmediateAddButton [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude;
		icon: (FontAwesomeIcons defaultStyle icon: #plus);
		label: 'Add item';
		action: [ :anElement | self onClick: anElement ];
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself
]

{ #category : 'private - accessing' }
CFMaAddItemViewModel >> newItemClasses [
	self description ifNil: [ ^ #() ].
	^ self description classes ifNil: [ #() ]
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newMenuItemForClass: aClass [
	| aMenuItem isDisabled |
	isDisabled := self shouldDisableNewItemClass: aClass.
	aMenuItem := BrMenuActionItem new.
	aMenuItem
		icon: aClass icon
		label: aClass displayString.
	aMenuItem
		disableIf: [ isDisabled ];
		action: [ :anElement :aButtonModel :anEvent |
			isDisabled ifFalse: [ self addItemForClass: aClass from: anElement ] ].
	^ aMenuItem
]

{ #category : 'private - event handling' }
CFMaAddItemViewModel >> onClick: anElement [
	self addItemForClass: self singleNewItemClass from: anElement
]

{ #category : 'private - testing' }
CFMaAddItemViewModel >> shouldDisableAddButton [
	self classStencil ifNotNil: [ ^ self hasNewItemClasses not ].
	^ self stencil isNil
]

{ #category : 'private - testing' }
CFMaAddItemViewModel >> shouldDisableNewItemClass: aClass [
	self memento ifNil: [ ^ true ].
	self description ifNil: [ ^ true ].
	aClass ifNil: [ ^ true ].
	^ self description isReadOnly
]

{ #category : 'private - testing' }
CFMaAddItemViewModel >> shouldShowNewItemClassChoiceMenu [
	^ self classStencil isNotNil and: [ self hasMultipleNewItemClasses ]
]

{ #category : 'private - accessing' }
CFMaAddItemViewModel >> singleNewItemClass [
	self newItemClasses size = 1
		ifTrue: [ ^ self newItemClasses first ].
	^ nil
]

{ #category : 'accessing' }
CFMaAddItemViewModel >> classStencil [
	^ classStencil
]

{ #category : 'accessing' }
CFMaAddItemViewModel >> classStencil: aStencil [
	classStencil := aStencil asStencilBuilder: CFMaNewItemStencilBuilder
]

{ #category : 'accessing' }
CFMaAddItemViewModel >> stencil: aStencil [
	super stencil: aStencil
]

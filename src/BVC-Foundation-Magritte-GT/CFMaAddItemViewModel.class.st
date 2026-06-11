Class {
	#name : 'CFMaAddItemViewModel',
	#superclass : 'CFMaAbstractAddItemViewModel',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'converting' }
CFMaAddItemViewModel >> asElement [
	self shouldUseCustomAddItemElement
		ifTrue: [ ^ self newCustomAddItemElement ].

	self shouldDisableAddButton
		ifTrue: [ ^ self newDisabledAddButton ].

	self shouldShowNewItemClassChoiceMenu
		ifTrue: [ ^ self newClassChoiceAddElement ].

	^ self newImmediateAddButton
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newImmediateAddButton [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude;
		icon: BrGlamorousVectorIcons add;
		label: 'Add item';
		action: [ :anElement | self onClick: anElement ];
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself
]


{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newDisabledAddButton [
	^ self newImmediateAddButton
		disable;
		yourself
]


{ #category : 'private - testing' }
CFMaAddItemViewModel >> shouldUseCustomAddItemElement [
	self stencil ifNil: [ ^ false ].
	(self stencil isKindOf: BrValuableStencil)
		ifTrue: [ ^ false ].
	^ self stencil isKindOf: BrStencil
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newCustomAddItemElement [
	self stencil
		memento: self memento;
		description: self description.
	^ self stencil asElement
]

{ #category : 'private - testing' }
CFMaAddItemViewModel >> hasNewItemClasses [
	^ self newItemClasses notEmpty
]

{ #category : 'private - testing' }
CFMaAddItemViewModel >> hasMultipleNewItemClasses [
	self description ifNil: [ ^ false ].
	^ self newItemClasses size > 1
]


{ #category : 'private - testing' }
CFMaAddItemViewModel >> shouldDisableAddButton [
	^ self stencilRequiresNewItemClass and: [ self hasNewItemClasses not ]
]

{ #category : 'private - testing' }
CFMaAddItemViewModel >> stencilRequiresNewItemClass [
	self stencil ifNil: [ ^ false ].
	(self stencil isKindOf: BrValuableStencil)
		ifFalse: [ ^ false ].
	^ self stencil valuable numArgs > 0
]

{ #category : 'private - accessing' }
CFMaAddItemViewModel >> newItemClasses [
	self description ifNil: [ ^ #() ].
	^ self description classes ifNil: [ #() ]
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
		icon: BrGlamorousVectorIcons add;
		label: 'Add item';
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newClassChoiceHandle [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude - BrGlamorousButtonExteriorAptitude;
		icon: BrGlamorousVectorIcons add;
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

{ #category : 'private - testing' }
CFMaAddItemViewModel >> shouldDisableNewItemClass: aClass [
	| aNewItem anExistingItems aNewItems |
	self memento ifNil: [ ^ true ].
	self description ifNil: [ ^ true ].

	aNewItem := self createItemForClass: aClass.
	aNewItem ifNil: [ ^ true ].

	anExistingItems := self memento readUsing: self description.
	anExistingItems ifNil: [ anExistingItems := #() ].
	aNewItems := anExistingItems copyWith: aNewItem.

	[ self description validate: aNewItems ]
		on: Error
		do: [ :anException | ^ true ].

	^ false
]

{ #category : 'private - event handling' }
CFMaAddItemViewModel >> onClick: anElement [
	self addItemForClass: self singleNewItemClass from: anElement
]

{ #category : 'private - accessing' }
CFMaAddItemViewModel >> singleNewItemClass [
	self newItemClasses size = 1
		ifTrue: [ ^ self newItemClasses first ].
	^ nil
]

{ #category : 'private - adding' }
CFMaAddItemViewModel >> addItemForClass: aClass from: anElement [
	| aNewItem anExistingItems aNewItems |
	self memento ifNil: [ ^ self ].
	self description ifNil: [ ^ self ].

	aNewItem := self createItemForClass: aClass.
	aNewItem ifNil: [ ^ self ].

	anExistingItems := self memento readUsing: self description.
	aNewItems := anExistingItems copyWith: aNewItem.

	GtMagritteBuilderUtility
		write: aNewItems
		using: self description
		memento: self memento
		element: anElement
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> createItemForClass: aClass [
	| aNewItem |
	self stencil ifNil: [
		aClass ifNil: [ ^ nil ].
		^ self configureParentForNewItem: aClass new ].

	aClass ifNil: [
		aNewItem := self stencil create.
		^ self configureParentForNewItem: aNewItem ].

	self stencil arguments: { aClass }.
	aNewItem := self stencil create.
	^ self configureParentForNewItem: aNewItem
]

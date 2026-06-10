Class {
	#name : 'CFMaToOneAddItemViewModel',
	#superclass : 'GtMagritteAddItemViewModel',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'converting' }
CFMaToOneAddItemViewModel >> asElement [
	self shouldUseCustomAddItemElement
		ifTrue: [ ^ self newCustomAddItemElement ].

	self shouldDisableAddButton
		ifTrue: [ ^ self newDisabledAddButton ].

	self shouldShowNewItemClassChoiceMenu
		ifTrue: [ ^ self newClassChoiceAddElement ].

	^ self newImmediateAddButton
]

{ #category : 'private - instance creation' }
CFMaToOneAddItemViewModel >> newImmediateAddButton [
	^ self installAddButtonEnablementOn: (BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude;
		icon: BrGlamorousVectorIcons add;
		label: 'Add item';
		action: [ :anElement | self onClick: anElement ];
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself)
]

{ #category : 'private - instance creation' }
CFMaToOneAddItemViewModel >> newDisabledAddButton [
	^ self newImmediateAddButton
		disable;
		yourself
]

{ #category : 'private - installing' }
CFMaToOneAddItemViewModel >> installAddButtonEnablementOn: aButton [
	self memento ifNil: [ ^ aButton disable; yourself ].
	self description ifNil: [ ^ aButton disable; yourself ].

	aButton
		withAsyncSinkDo: [ :anElementSink |
			anElementSink
				sink: AsyncPeekSink new;
				whenUpdate: [ :theButton :aSink |
					(aSink value currentValue isNil and: [ self shouldDisableAddButton not ])
						ifTrue: [ theButton enable ]
						ifFalse: [ theButton disable ] ].
			(self memento readObservableValueUsing: self description)
				observe: anElementSink ].

	^ aButton
]

{ #category : 'private - testing' }
CFMaToOneAddItemViewModel >> shouldUseCustomAddItemElement [
	self stencil ifNil: [ ^ false ].
	(self stencil isKindOf: BrValuableStencil)
		ifTrue: [ ^ false ].
	^ self stencil isKindOf: BrStencil
]

{ #category : 'private - instance creation' }
CFMaToOneAddItemViewModel >> newCustomAddItemElement [
	self stencil
		memento: self memento;
		description: self description.
	^ self stencil asElement
]

{ #category : 'private - testing' }
CFMaToOneAddItemViewModel >> shouldDisableAddButton [
	^ self stencilRequiresNewItemClass and: [ self hasNewItemClasses not ]
]

{ #category : 'private - testing' }
CFMaToOneAddItemViewModel >> shouldShowNewItemClassChoiceMenu [
	^ self stencilRequiresNewItemClass and: [ self hasMultipleNewItemClasses ]
]

{ #category : 'private - testing' }
CFMaToOneAddItemViewModel >> stencilRequiresNewItemClass [
	self stencil ifNil: [ ^ false ].
	(self stencil isKindOf: BrValuableStencil)
		ifFalse: [ ^ false ].
	^ self stencil valuable numArgs > 0
]

{ #category : 'private - testing' }
CFMaToOneAddItemViewModel >> hasNewItemClasses [
	^ self newItemClasses notEmpty
]

{ #category : 'private - testing' }
CFMaToOneAddItemViewModel >> hasMultipleNewItemClasses [
	self description ifNil: [ ^ false ].
	^ self newItemClasses size > 1
]

{ #category : 'private - accessing' }
CFMaToOneAddItemViewModel >> newItemClasses [
	self description ifNil: [ ^ #() ].
	^ self description classes ifNil: [ #() ]
]

{ #category : 'private - accessing' }
CFMaToOneAddItemViewModel >> singleNewItemClass [
	self newItemClasses size = 1
		ifTrue: [ ^ self newItemClasses first ].
	^ nil
]

{ #category : 'private - instance creation' }
CFMaToOneAddItemViewModel >> newClassChoiceAddElement [
	^ self installAddButtonEnablementOn: (BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude
			+ (BrGlamorousWithExplicitDropdownAptitude
				handle: [ self newClassChoiceHandle ]
				menu: [ self newClassChoiceMenu ]);
		icon: BrGlamorousVectorIcons add;
		label: 'Add item';
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself)
]

{ #category : 'private - instance creation' }
CFMaToOneAddItemViewModel >> newClassChoiceHandle [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude - BrGlamorousButtonExteriorAptitude;
		icon: BrGlamorousVectorIcons add;
		label: 'Add item';
		yourself
]

{ #category : 'private - instance creation' }
CFMaToOneAddItemViewModel >> newClassChoiceMenu [
	| aMenu |
	aMenu := BrMenuItems new.
	aMenu beListElementType.
	self newItemClasses do: [ :aClass |
		aMenu addItem: (self newMenuItemForClass: aClass) ].
	^ aMenu
]

{ #category : 'private - instance creation' }
CFMaToOneAddItemViewModel >> newMenuItemForClass: aClass [
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
CFMaToOneAddItemViewModel >> shouldDisableNewItemClass: aClass [
	| aNewItem |
	self memento ifNil: [ ^ true ].
	self description ifNil: [ ^ true ].

	aNewItem := self createItemForClass: aClass.
	aNewItem ifNil: [ ^ true ].

	[ self description validate: aNewItem ]
		on: Error
		do: [ :anException | ^ true ].

	^ false
]

{ #category : 'private - event handling' }
CFMaToOneAddItemViewModel >> onClick: anElement [
	self addItemForClass: self singleNewItemClass from: anElement
]

{ #category : 'private - adding' }
CFMaToOneAddItemViewModel >> addItemForClass: aClass from: anElement [
	| aNewItem |
	self memento ifNil: [ ^ self ].
	self description ifNil: [ ^ self ].

	aNewItem := self createItemForClass: aClass.
	aNewItem ifNil: [ ^ self ].

	GtMagritteBuilderUtility
		write: aNewItem
		using: self description
		memento: self memento
		element: anElement
]

{ #category : 'private - instance creation' }
CFMaToOneAddItemViewModel >> createItemForClass: aClass [
	self stencil ifNil: [
		aClass ifNil: [ ^ nil ].
		^ aClass new ].

	aClass ifNil: [ ^ self stencil create ].

	self stencil arguments: { aClass }.
	^ self stencil create
]

Class {
	#name : 'CFMaAddItemViewModel',
	#superclass : 'GtMagritteAddItemViewModel',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'converting' }
CFMaAddItemViewModel >> asElement [
	self hasMultipleNewItemClasses
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

{ #category : 'private - testing' }
CFMaAddItemViewModel >> hasMultipleNewItemClasses [
	self description ifNil: [ ^ false ].
	^ self newItemClasses size > 1
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
			+ (BrGlamorousWithExplicitDropdownAptitude
				handle: [ self newClassChoiceHandle ]
				menu: [ self newClassChoiceMenu ]);
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
		(aClass respondsTo: #icon)
			ifTrue: [
				aMenu
					addItemIcon: aClass icon
					label: aClass displayString
					action: [ :anElement :aButtonModel :anEvent |
						self addItemForClass: aClass from: anElement ] ]
			ifFalse: [
				aMenu
					addItemLabel: aClass displayString
					action: [ :anElement :aButtonModel :anEvent |
						self addItemForClass: aClass from: anElement ] ] ].
	^ aMenu
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
	self stencil ifNil: [
		aClass ifNil: [ ^ nil ].
		^ aClass new ].

	aClass ifNil: [ ^ self stencil create ].

	(self stencil respondsTo: #arguments:)
		ifTrue: [
			self stencil arguments: { aClass }.
			^ self stencil create ].

	^ self stencil create
]

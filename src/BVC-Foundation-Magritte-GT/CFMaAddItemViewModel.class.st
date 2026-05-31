Class {
	#name : 'CFMaAddItemViewModel',
	#superclass : 'GtMagritteAddItemViewModel',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - adding' }
CFMaAddItemViewModel >> addChoice: aChoice from: anElement [
	| aNewItem |
	self description ifNil: [ ^ self ].

	aNewItem := self description createAddItemFromChoice: aChoice.
	aNewItem ifNil: [ ^ self ].

	self addItem: aNewItem from: anElement
]

{ #category : 'api - adding' }
CFMaAddItemViewModel >> addItem: aNewItem from: anElement [
	| anExistingItems aNewItems |
	self memento ifNil: [ ^ self ].
	self description ifNil: [ ^ self ].

	anExistingItems := self memento readUsing: self description.
	anExistingItems ifNil: [ anExistingItems := #() ].
	aNewItems := anExistingItems copyWith: aNewItem.

	GtMagritteBuilderUtility
		write: aNewItems
		using: self description
		memento: self memento
		element: anElement
]

{ #category : 'converting' }
CFMaAddItemViewModel >> asElement [
	self description ifNil: [ ^ super asElement ].

	self description hasAddItemChoices
		ifTrue: [ ^ self newChoiceAddElement ].

	^ self newImmediateAddButton
]

{ #category : 'api - adding' }
CFMaAddItemViewModel >> createAndAddFrom: anElement [
	| aNewItem |
	self description ifNil: [ ^ self ].

	aNewItem := self description createAddItem.
	aNewItem ifNil: [ ^ self ].

	self addItem: aNewItem from: anElement
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> labelForChoice: aChoice [
	(aChoice respondsTo: #serviceAddMenuDisplayName)
		ifTrue: [ ^ aChoice serviceAddMenuDisplayName ].

	(aChoice respondsTo: #name)
		ifTrue: [ ^ aChoice name ].

	^ aChoice asString
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newAddButtonHandle [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude;
		icon: BrGlamorousVectorIcons add;
		label: 'Add item';
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newChoiceAddElement [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude
			+ (BrGlamorousWithExplicitDropdownAptitude
				handle: [ self newAddButtonHandle ]
				content: [ self newChoicesListElement ]);
		icon: BrGlamorousVectorIcons add;
		label: 'Add item';
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newChoicesListElement [
	^ BrSimpleList new
		itemStencil: [ BrButton new
			hMatchParent;
			aptitude: BrGlamorousButtonWithLabelAptitude;
			yourself ];
		itemDataBinder: [ :aButton :eachChoice |
			aButton
				label: (self labelForChoice: eachChoice);
				action: [ :aButtonElement |
					self addChoice: eachChoice from: aButtonElement.
					aButtonElement fireEvent: BrDropdownHideWish new ] ];
		items: self description addItemChoices;
		hFitContent;
		vFitContent;
		yourself
]

{ #category : 'private - instance creation' }
CFMaAddItemViewModel >> newImmediateAddButton [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude;
		icon: BrGlamorousVectorIcons add;
		label: 'Add item';
		action: [ :anElement | self createAndAddFrom: anElement ];
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself
]

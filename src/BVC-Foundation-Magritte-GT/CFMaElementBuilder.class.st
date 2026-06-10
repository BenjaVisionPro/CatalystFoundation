Class {
	#name : 'CFMaElementBuilder',
	#superclass : 'GtMagritteElementBuilder',
	#instVars : [
		'currentGroup'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'elements' }
CFMaElementBuilder >> addFieldElement: aFieldElement using: aDescription [
	| aLabel |
	self emitGroupFor: aDescription.

	aLabel := self builderUtilityClass newFieldLabelUsing: aDescription.

	aDescription hasComment
		ifTrue: [ self builderUtilityClass addCommentTooltip: aLabel using: aDescription.
			self builderUtilityClass addCommentTooltip: aFieldElement using: aDescription ].

	self fieldContainerDo: [ :aContainer |
		aContainer
			addChild: aLabel;
			addChild: aFieldElement ].

	^ aLabel
]

{ #category : 'defaults' }
CFMaElementBuilder >> builderUtilityClass [
	^ CFMaBuilderUtility
]


{ #category : 'private - building' }
CFMaElementBuilder >> addFlowListUsing: aDescription [
	| aMemento aFlowElement |
	aMemento := self memento.
	
	aFlowElement := aDescription blocListStencil
		memento: aMemento;
		description: aDescription;
		form: self form;
		asElement.

	self addShortcutsTo: aFlowElement using: aDescription.
	self addFieldElement: aFlowElement using: aDescription
]

{ #category : 'private - building' }
CFMaElementBuilder >> addFormNavigationShortcutsTo: anElement [
	anElement
		addShortcut: (BlShortcutWithAction new
			name: 'Move to next form item';
			description: 'Moves to the next form item. If none is found, we cycle back to the first.';
			combination: (BlKeyCombination tab or: BlKeyCombination enter);
			overrideChildren: true;
			action: [ :anEvent |
				BlFocusFinder new
					direction: BlFocusSearchDirectionForward new;
					root: self formNavigationRoot;
					referenceElement: anEvent target;
					nextFocusDo: #requestFocus
					ifNone: [  ] ]);
		addShortcut: (BlShortcutWithAction new
			name: 'Move to previous form item';
			description: 'Moves to the previous form item. If none is found, we cycle back to the last.';
			combination: BlKeyCombination shiftTab;
			overrideChildren: true;
			action: [ :anEvent |
				BlFocusFinder new
					direction: BlFocusSearchDirectionBackward new;
					root: self formNavigationRoot;
					referenceElement: anEvent target;
					nextFocusDo: #requestFocus
					ifNone: [  ] ])
]

{ #category : 'private - building' }
CFMaElementBuilder >> addFormResetShortcutTo: anElement [
	anElement
		addShortcut: (BlShortcutWithAction new
			name: 'Discard form contents';
			description: 'Discards the form contents and resets the form to its original state';
			combination: BlKeyCombination escape;
			overrideChildren: true;
			action: [ :anEvent |
				| aFuture |
				aFuture := [ self
					resetFrom: self form
					usingModel: self memento model
					andMemento: self memento ] asAsyncFuture.
				self builderUtilityClass
					awaitFuture: aFuture
					from: anEvent currentTarget ])
]

{ #category : 'private - building' }
CFMaElementBuilder >> addShortcutsTo: anElement [
	self addFormResetShortcutTo: anElement.
	self addFormNavigationShortcutsTo: anElement
]

{ #category : 'private - building' }
CFMaElementBuilder >> addShortcutsTo: anElement using: aDescription [
	self addShortcutsTo: anElement.

	aDescription blocShortcuts
		ifNotNil: [ :aBlockReturningCollection |
			aBlockReturningCollection value do: [ :aShortcut |
				anElement addShortcut: aShortcut ] ]
]


{ #category : 'private - building' }
CFMaElementBuilder >> emitGroupFor: aDescription [
	| aGroupName |
	aGroupName := aDescription cfCategory.
	aGroupName ifNil: [ ^ self ].
	currentGroup = aGroupName ifTrue: [ ^ self ].
	currentGroup := aGroupName.
	self fieldContainerDo: [ :aContainer |
		aContainer addChild: (self builderUtilityClass newGroupLabelUsing: aGroupName) ]
]

{ #category : 'visiting-description' }
CFMaElementBuilder >> visitToOneRelationDescription: aDescription [
	self addToOneUsing: aDescription
]

{ #category : 'private - building' }
CFMaElementBuilder >> addToOneUsing: aDescription [
	| aMemento anElement |
	aMemento := self memento.

	anElement := aDescription blocStencil
		memento: aMemento;
		description: aDescription;
		form: self form;
		asElement.

	self addShortcutsTo: anElement using: aDescription.
	self addFieldElement: anElement using: aDescription
]


{ #category : 'private - building' }
CFMaElementBuilder >> buildActions [
	| aToolbar allActions |
	allActions := self allActions.
	allActions ifEmpty: [ ^ self ].

	self toolbarContainerDo: [ :aContainer |
		aToolbar := self builderUtilityClass
			newToolbarWithActions: allActions
			memento: self memento.

		self addFormNavigationShortcutsTo: aToolbar.

		aContainer addChild: aToolbar as: #toolbar ]
]

{ #category : 'private - building' }
CFMaElementBuilder >> formNavigationRoot [
	| aRoot |
	aRoot := self form.
	self form magritte fieldContainerDo: [ :aFieldContainer |
		aRoot := aFieldContainer ].
	^ aRoot
]



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
CFMaElementBuilder >> emitGroupFor: aDescription [
	| aGroupName |
	(aDescription respondsTo: #group) ifFalse: [ ^ self ].
	aGroupName := aDescription perform: #group.
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

	self addFieldElement: anElement using: aDescription
]


{ #category : 'private - building' }
CFMaElementBuilder >> addShortcutsTo: anElement [
	| aNavigationRoot |
	aNavigationRoot := self form.
	self fieldContainerDo: [ :aFieldContainer | aNavigationRoot := aFieldContainer ].

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
					from: anEvent currentTarget ]).

	CFMaBuilderUtility
		installRelationEditorNavigationShortcutsOn: anElement
		form: aNavigationRoot
]

{ #category : 'private - building' }
CFMaElementBuilder >> addShortcutsTo: anElement using: aDescription [
	self addShortcutsTo: anElement.

	aDescription blocShortcuts
		ifNotNil: [ :aBlockReturningCollection |
			aBlockReturningCollection value do: [ :aShortcut | anElement addShortcut: aShortcut ] ]
]

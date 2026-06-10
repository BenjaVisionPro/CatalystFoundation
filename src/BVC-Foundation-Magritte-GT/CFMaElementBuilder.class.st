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
				self
					debugFormNavigationFrom: anEvent
					direction: BlFocusSearchDirectionForward new
					label: 'forward'.
				BlFocusFinder new
					direction: BlFocusSearchDirectionForward new;
					root: self formNavigationRoot;
					referenceElement: anEvent target;
					nextFocusDo: #requestFocus
					ifNone: [ self requestFirstFormFocus ] ]);
		addShortcut: (BlShortcutWithAction new
			name: 'Move to previous form item';
			description: 'Moves to the previous form item. If none is found, we cycle back to the last.';
			combination: BlKeyCombination shiftTab;
			overrideChildren: true;
			action: [ :anEvent |
				self
					debugFormNavigationFrom: anEvent
					direction: BlFocusSearchDirectionBackward new
					label: 'backward'.
				BlFocusFinder new
					direction: BlFocusSearchDirectionBackward new;
					root: self formNavigationRoot;
					referenceElement: anEvent target;
					nextFocusDo: #requestFocus
					ifNone: [ self requestLastFormFocus ] ])
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


{ #category : 'debugging' }
CFMaElementBuilder >> debugDescriptionForElement: anElement [
	^ String streamContents: [ :aStream |
		aStream
			nextPutAll: anElement class name asString;
			nextPutAll: ' id=';
			nextPutAll: anElement id printString;
			nextPutAll: ' focusability=';
			nextPutAll: anElement focusability printString;
			nextPutAll: ' isFocused=';
			nextPutAll: anElement isFocused printString;
			nextPutAll: ' hasFocus=';
			nextPutAll: anElement hasFocus printString;
			nextPutAll: ' isVisible=';
			nextPutAll: anElement isVisible printString ]
]

{ #category : 'debugging' }
CFMaElementBuilder >> debugFormNavigationFrom: anEvent direction: aDirection label: aLabel [
	| aRoot theCandidates anIndex |
	aRoot := self formNavigationRoot.
	theCandidates := BlFocusFinder new
		root: aRoot;
		direction: aDirection;
		focusableCandidates.

	(String streamContents: [ :aStream |
		aStream
			nextPutAll: 'CF form navigation ';
			nextPutAll: aLabel;
			nextPutAll: ' target=[';
			nextPutAll: (self debugDescriptionForElement: anEvent target);
			nextPutAll: '] currentTarget=[';
			nextPutAll: (self debugDescriptionForElement: anEvent currentTarget);
			nextPutAll: '] root=[';
			nextPutAll: (self debugDescriptionForElement: aRoot);
			nextPutAll: '] candidateCount=';
			nextPutAll: theCandidates size printString ]) traceCr.

	anIndex := 0.
	theCandidates do: [ :eachElement |
		anIndex := anIndex + 1.
		(String streamContents: [ :aStream |
			aStream
				nextPutAll: '  ';
				nextPutAll: anIndex printString;
				nextPutAll: '. ';
				nextPutAll: (self debugDescriptionForElement: eachElement) ]) traceCr ]
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

	self addShortcutsTo: anElement using: aDescription.
	self addFieldElement: anElement using: aDescription
]


{ #category : 'private - building' }
CFMaElementBuilder >> formNavigationRoot [
	| aRoot |
	aRoot := self form.
	self form magritte fieldContainerDo: [ :aFieldContainer |
		aRoot := aFieldContainer ].
	^ aRoot
]

{ #category : 'private - building' }
CFMaElementBuilder >> requestFirstFormFocus [
	| theCandidates |
	theCandidates := BlFocusFinder new
		root: self formNavigationRoot;
		direction: BlFocusSearchDirectionForward new;
		focusableCandidates.
	theCandidates isEmpty
		ifFalse: [ (theCandidates at: 1) requestFocus ]
]

{ #category : 'private - building' }
CFMaElementBuilder >> requestLastFormFocus [
	| theCandidates |
	theCandidates := BlFocusFinder new
		root: self formNavigationRoot;
		direction: BlFocusSearchDirectionBackward new;
		focusableCandidates.
	theCandidates isEmpty
		ifFalse: [ (theCandidates at: theCandidates size) requestFocus ]
]

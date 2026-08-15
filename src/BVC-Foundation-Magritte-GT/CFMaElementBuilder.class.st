Class {
	#name : 'CFMaElementBuilder',
	#superclass : 'GtMagritteElementBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'elements' }
CFMaElementBuilder >> addFieldElement: aFieldElement using: aDescription [
	| aLabel aText aLabelAptitude |
	"Foundation keeps GT field construction wherever its behaviour is sufficient.
	This method supplies Foundation's shared label chrome; relation visitors may
	provide Foundation editors where GT does not provide the required capability."
	aText := aDescription label asRopedText.
	aDescription isRequired ifTrue: [ aText append: '*' asRopedText ].
	aLabelAptitude := aDescription labelAptitude
		ifNil: [ BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.52);
			fontSize: 13 ]
		ifNotNil: #value.
	aLabel := BrLabel new
		id: (GtMagritteFieldLabelId new description: aDescription);
		text: aText;
		aptitude: aLabelAptitude;
		fitContent;
		margin: (BlInsets top: 3 right: 12 bottom: 6 left: 0);
		constraintsDo: [ :c | c grid vertical alignTop ].

	aDescription hasComment ifTrue: [
		GtMagritteBuilderUtility addCommentTooltip: aLabel using: aDescription.
		GtMagritteBuilderUtility addCommentTooltip: aFieldElement using: aDescription ].

	aFieldElement constraintsDo: [ :c |
		c horizontal matchParent.
		c grid horizontal weight: 1 ].

	self configureTabStopFor: aFieldElement using: aDescription.

	self labelContainerDo: [ :aContainer | aContainer addChild: aLabel ].
	self fieldContainerDo: [ :aContainer | aContainer addChild: aFieldElement ].
	^ aLabel
]


{ #category : 'visiting-description' }
CFMaElementBuilder >> visitToOneRelationDescription: aDescription [
	aDescription blocStencil
		ifNil: [ ^ super visitToOneRelationDescription: aDescription ]
		ifNotNil: [ :aStencil |
			self
				addFieldElement: (aStencil
					memento: self memento;
					description: aDescription;
					asElement)
				using: aDescription ]
]


{ #category : 'private - focus' }
CFMaElementBuilder >> navigationRootFor: anElement [
	| aCurrentElement aRootElement |
	aCurrentElement := anElement.
	aRootElement := self form.

	[ aCurrentElement isNotNil ] whileTrue: [
		(aCurrentElement isKindOf: CFMaFormRootElement)
			ifTrue: [ aRootElement := aCurrentElement ].
		aCurrentElement := aCurrentElement parent ].

	^ aRootElement
]

{ #category : 'private - focus' }
CFMaElementBuilder >> moveFocusFrom: anElement inDirection: aDirection [
	| aNavigationRoot aReferenceElement |
	aNavigationRoot := self navigationRootFor: anElement.
	aReferenceElement := anElement space
		ifNil: [ anElement ]
		ifNotNil: [ :aSpace | aSpace focusOwner ifNil: [ anElement ] ].

	BlFocusFinder new
		direction: aDirection;
		root: aNavigationRoot;
		referenceElement: aReferenceElement;
		nextFocusDo: #requestFocus ifNone: [  ]
]

{ #category : 'private - focus' }
CFMaElementBuilder >> installFormNavigationOn: anElement [
	(anElement userData includesKey: #cfMaFormNavigation)
		ifTrue: [ ^ anElement ].

	anElement userData at: #cfMaFormNavigation put: true.
	anElement
		addShortcut: (BlShortcutWithAction new
			name: 'Discard form contents';
			description: 'Discards the complete Foundation form transaction.';
			combination: BlKeyCombination escape;
			overrideChildren: true;
			action: [ :anEvent |
				| aNavigationRoot aNavigationMemento aFuture |
				aNavigationRoot := self navigationRootFor: anEvent target.
				aNavigationMemento := aNavigationRoot userData
					at: GtMagritteViewModel gtMementoSymbol
					ifAbsent: [ self memento ].
				aFuture := [ self
					resetFrom: aNavigationRoot
					usingModel: aNavigationMemento model
					andMemento: aNavigationMemento ] asAsyncFuture.
				GtMagritteBuilderUtility
					awaitFuture: aFuture
					from: anEvent currentTarget ]);
		addShortcut: (BlShortcutWithAction new
			name: 'Move to next form description';
			description: 'Moves to the next Magritte description in the complete Foundation form.';
			combination: (BlKeyCombination tab or: BlKeyCombination enter);
			overrideChildren: true;
			action: [ :anEvent |
				anEvent consumed: true.
				self
					moveFocusFrom: anEvent target
					inDirection: BlFocusSearchDirectionForward new ]);
		addShortcut: (BlShortcutWithAction new
			name: 'Move to previous form description';
			description: 'Moves to the previous Magritte description in the complete Foundation form.';
			combination: BlKeyCombination shiftTab;
			overrideChildren: true;
			action: [ :anEvent |
				anEvent consumed: true.
				self
					moveFocusFrom: anEvent target
					inDirection: BlFocusSearchDirectionBackward new ]).
	^ anElement
]

{ #category : 'private - building' }
CFMaElementBuilder >> addShortcutsTo: anElement [
	self installFormNavigationOn: anElement
]

{ #category : 'private - building' }
CFMaElementBuilder >> addShortcutsTo: anElement using: aDescription [
	self installFormNavigationOn: anElement.

	aDescription blocShortcuts
		ifNotNil: [ :aBlockReturningCollection |
			aBlockReturningCollection value do: [ :aShortcut |
				anElement addShortcut: aShortcut ] ]
]






{ #category : 'private - focus' }
CFMaElementBuilder >> configureTabStopFor: aFieldElement using: aDescription [
	"Keep GT/Brick's native focusable descendants. The field surface only
	participates when there are no focusable descendants of its own."
	aFieldElement focusability: BlFocusability after.
	self installFormNavigationOn: aFieldElement.
	^ aFieldElement
]

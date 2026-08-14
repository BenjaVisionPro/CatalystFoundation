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
	BlFocusFinder new
		direction: aDirection;
		root: (self navigationRootFor: anElement);
		referenceElement: anElement;
		nextFocusDo: #requestFocus ifNone: [  ]
]

{ #category : 'private - building' }
CFMaElementBuilder >> addShortcutsTo: anElement [
	anElement
		addShortcut: (BlShortcutWithAction new
			name: 'Discard form contents';
			description: 'Discards the form contents and resets the form to its original state';
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
			name: 'Move to next form item';
			description: 'Moves to the next form item in the complete Foundation form.';
			combination: (BlKeyCombination tab or: BlKeyCombination enter);
			overrideChildren: true;
			action: [ :anEvent |
				self
					moveFocusFrom: anEvent target
					inDirection: BlFocusSearchDirectionForward new ]);
		addShortcut: (BlShortcutWithAction new
			name: 'Move to previous form item';
			description: 'Moves to the previous form item in the complete Foundation form.';
			combination: BlKeyCombination shiftTab;
			overrideChildren: true;
			action: [ :anEvent |
				self
					moveFocusFrom: anEvent target
					inDirection: BlFocusSearchDirectionBackward new ])
]

{ #category : 'private - building' }
CFMaElementBuilder >> addShortcutsTo: anElement using: aDescription [
	self addShortcutsTo: anElement.

	aDescription blocShortcuts
		ifNotNil: [ :aBlockReturningCollection |
			aBlockReturningCollection value do: [ :aShortcut |
				anElement addShortcut: aShortcut ] ]
]

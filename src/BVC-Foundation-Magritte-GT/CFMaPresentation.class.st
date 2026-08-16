"I am Foundation's Magritte presentation. I participate directly in Magritte's visitor rendering path and own the composition of fields and groups for one form build."

Class {
	#name : 'CFMaPresentation',
	#superclass : 'GtMagritteElementBuilder',
	#instVars : [
		'hostElement',
		'containersByGroup',
		'ungroupedContainer',
		'identityAffordanceEmitted'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'initialization' }
CFMaPresentation >> initialize [
	super initialize.
	containersByGroup := Dictionary new.
	identityAffordanceEmitted := false
]

{ #category : 'api - building' }
CFMaPresentation >> build [
	identityAffordanceEmitted := false.
	containersByGroup removeAll.
	ungroupedContainer := nil.
	self fieldContainerDo: [ :anElement | hostElement := anElement ].
	^ super build
]

{ #category : 'visiting' }
CFMaPresentation >> visit: aDescription [
	(aDescription respondsTo: #cfCategory)
		ifTrue: [
			aDescription cfCategory = #identity
				ifTrue: [
					self emitIdentityAffordanceUsing: aDescription.
					^ self ] ].
	^ super visit: aDescription
]

{ #category : 'private - identity' }
CFMaPresentation >> emitIdentityAffordanceUsing: aDescription [
	identityAffordanceEmitted ifTrue: [ ^ self ].
	identityAffordanceEmitted := true.

	self
		addElement: (CFMaIdentityAffordanceElement new
			memento: self memento;
			yourself)
		for: aDescription
]

{ #category : 'elements' }
CFMaPresentation >> addFieldElement: aFieldElement using: aDescription [
	| aLabel aText aLabelAptitude |
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
		fitContent.

	aDescription hasComment ifTrue: [
		GtMagritteBuilderUtility addCommentTooltip: aLabel using: aDescription.
		GtMagritteBuilderUtility addCommentTooltip: aFieldElement using: aDescription ].

	self configureTabStopFor: aFieldElement using: aDescription.
	self addLabel: aLabel field: aFieldElement for: aDescription.
	^ aLabel
]

{ #category : 'private - composition' }
CFMaPresentation >> addLabel: aLabel field: aFieldElement for: aDescription [
	self
		addLabel: aLabel
		field: aFieldElement
		to: (self containerForGroup: aDescription group)
]

{ #category : 'private - composition' }
CFMaPresentation >> addElement: anElement for: aDescription [
	self
		addElement: anElement
		to: (self containerForGroup: aDescription group)
]

{ #category : 'private - composition' }
CFMaPresentation >> addLabel: aLabel field: aFieldElement to: aContainer [
	aLabel margin: (BlInsets top: 3 right: 0 bottom: 2 left: 0).
	aFieldElement constraintsDo: [ :c | c horizontal matchParent ].

	aContainer
		addChild: aLabel;
		addChild: aFieldElement
]

{ #category : 'private - composition' }
CFMaPresentation >> addElement: anElement to: aContainer [
	aContainer addChild: anElement
]

{ #category : 'private - composition' }
CFMaPresentation >> newFieldContainer [
	^ BrVerticalPane new
		background: Color transparent;
		border: BlBorder empty;
		margin: BlInsets empty;
		cellSpacing: 4;
		hMatchParent;
		vFitContent;
		yourself
]

{ #category : 'private - groups' }
CFMaPresentation >> containerForGroup: aGroup [
	aGroup ifNil: [
		^ ungroupedContainer ifNil: [
			ungroupedContainer := self newFieldContainer.
			hostElement addChild: ungroupedContainer.
			ungroupedContainer ] ].

	^ containersByGroup
		at: aGroup
		ifAbsentPut: [ self newGroupNamed: aGroup ]
]

{ #category : 'private - groups' }
CFMaPresentation >> newGroupNamed: aGroup [
	| aSection aHeading aContainer |
	aHeading := BrLabel new
		text: aGroup asString;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.68);
			fontSize: 14;
			bold);
		fitContent;
		margin: (BlInsets top: 10 right: 0 bottom: 4 left: 0);
		yourself.

	aContainer := self newFieldContainer.
	aSection := BrVerticalPane new
		hMatchParent;
		vFitContent;
		addChild: aHeading;
		addChild: aContainer;
		yourself.

	hostElement addChild: aSection.
	^ aContainer
]

{ #category : 'private - groups' }
CFMaPresentation >> hostElement [
	^ hostElement
]

{ #category : 'visiting-description' }
CFMaPresentation >> visitToOneRelationDescription: aDescription [
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
CFMaPresentation >> navigationRootFor: anElement [
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
CFMaPresentation >> moveFocusFrom: anElement inDirection: aDirection [
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
CFMaPresentation >> installFormNavigationOn: anElement [
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
CFMaPresentation >> addShortcutsTo: anElement [
	self installFormNavigationOn: anElement
]

{ #category : 'private - building' }
CFMaPresentation >> addShortcutsTo: anElement using: aDescription [
	self installFormNavigationOn: anElement.

	aDescription blocShortcuts
		ifNotNil: [ :aBlockReturningCollection |
			aBlockReturningCollection value do: [ :aShortcut |
				anElement addShortcut: aShortcut ] ]
]






{ #category : 'private - focus' }
CFMaPresentation >> configureTabStopFor: aFieldElement using: aDescription [
	"Keep GT/Brick's native focusable descendants. The field surface only
	participates when there are no focusable descendants of its own."
	aFieldElement focusability: BlFocusability after.
	self installFormNavigationOn: aFieldElement.
	^ aFieldElement
]

"
I am Foundation's Magritte presentation. I participate directly in Magritte's visitor rendering path and own the composition of fields and groups for one form build.
"
Class {
	#name : 'CFMaPresentation',
	#superclass : 'GtMagritteElementBuilder',
	#instVars : [
		'hostElement',
		'containersByGroup',
		'ungroupedContainer',
		'identityAffordanceEmitted',
		'fieldConfigurationOverrides',
		'fieldConfigurations'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'private - building' }
CFMaPresentation >> addBooleanField: aDescription [
	| aCheckBoxElement aMemento aLabel |
	aMemento := self memento.

	aDescription blocStencil
		ifNotNil: [ :stencil |
			aCheckBoxElement := stencil
				memento: aMemento;
				description: aDescription;
				asElement ]
		ifNil: [
			aCheckBoxElement := GtMagritteBooleanElement new
				fieldViewModel: (GtMagritteFieldViewModel new
					memento: aMemento;
					description: aDescription) ].

	aLabel := self addFieldElement: aCheckBoxElement using: aDescription.
	aDescription hasCustomLabels ifTrue: [
		aLabel padding: aLabel padding + (BlInsets top: self defaultSpacing) ]
]

{ #category : 'private - building' }
CFMaPresentation >> addDirectoryDropdown: aDescription [
	| aButton |
	aButton := GtMagritteBuilderUtility
		newDirectoryDropdownMemento: self memento
		using: aDescription.
	self addFieldElement: aButton using: aDescription
]

{ #category : 'private - composition' }
CFMaPresentation >> addElement: anElement for: aDescription [
	self
		addElement: anElement
		to: (self containerForDescription: aDescription)
]

{ #category : 'private - composition' }
CFMaPresentation >> addElement: anElement to: aContainer [
	aContainer addChild: anElement
]

{ #category : 'elements' }
CFMaPresentation >> addFieldElement: aFieldElement using: aDescription [
	| aLabel aText aLabelAptitude |
	aText := aDescription label asRopedText.
	aDescription isRequired ifTrue: [ aText append: '*' asRopedText ].
	aLabelAptitude := aDescription labelAptitude
		ifNil: [ self defaultLabelAptitude ]
		ifNotNil: #value.
	aLabel := BrLabel new
		id: (GtMagritteFieldLabelId new description: aDescription);
		text: aText;
		aptitude: aLabelAptitude;
		fitContent.

	aDescription hasComment ifTrue: [
		self addCommentTooltipTo: aFieldElement using: aDescription ].

	self configureTabStopFor: aFieldElement using: aDescription.
	self addLabel: aLabel field: aFieldElement for: aDescription.
	^ aLabel
]

{ #category : 'private - composition' }
CFMaPresentation >> addCommentTooltipTo: aFieldElement using: aDescription [
	| aTooltipAptitude |
	aTooltipAptitude := BrGlamorousWithExplicitTooltipAptitude new
		handle: [ self newCommentTooltipHandle ]
		content: [ self newCommentTooltipFor: aDescription ].
	aTooltipAptitude menuContainerDo: [ :aContainer |
		self removePopoverContainerAptitudeFrom: aContainer.
		aContainer
			padding: BlInsets empty;
			geometry: (BrAnchoredGeometry cornerRadius: 6 element: aContainer);
			background: (Color white alpha: 0.85);
			border: BlBorder empty ].
	aFieldElement addAptitude: aTooltipAptitude
]

{ #category : 'private - composition' }
CFMaPresentation >> removePopoverContainerAptitudeFrom: aContainer [
	| aPopoverContainerAptitude |
	aPopoverContainerAptitude := nil.
	aContainer aptitudeDo: [ :anAptitude |
		(anAptitude isKindOf: BrPopoverContainerAptitude) ifTrue: [
			aPopoverContainerAptitude := anAptitude ] ].
	aPopoverContainerAptitude ifNotNil: [
		aContainer removeAptitude: aPopoverContainerAptitude ]
]

{ #category : 'private - composition' }
CFMaPresentation >> newCommentTooltipHandle [
	^ BlElement new
		size: BrMenuConstants handleExtent * 2.0;
		geometry: BlCircleGeometry new;
		background: Color transparent;
		border: BlBorder empty;
		yourself
]

{ #category : 'private - composition' }
CFMaPresentation >> newCommentTooltipFor: aDescription [
	^ BrLabel new
		fitContent;
		padding: (BlInsets top: 4 left: 8 bottom: 4 right: 8);
		aptitude: BrGlamorousLabelAptitude new glamorousRegularFontAndSize;
		text: aDescription comment;
		background: Color transparent;
		border: BlBorder empty;
		focusability: BlFocusability none;
		preventMouseEvents;
		yourself
]

{ #category : 'visiting-description' }
CFMaPresentation >> addFileDropdown: aDescription [
	| aButton |
	aButton := GtMagritteBuilderUtility
		newFileDropdownMemento: self memento
		using: aDescription.
	self addFieldElement: aButton using: aDescription
]

{ #category : 'private - composition' }
CFMaPresentation >> addLabel: aLabel field: aFieldElement for: aDescription [
	self
		addLabel: aLabel
		field: aFieldElement
		to: (self containerForDescription: aDescription)
]

{ #category : 'private - composition' }
CFMaPresentation >> addLabel: aLabel field: aFieldElement to: aContainer [
	aLabel margin: (BlInsets top: 3 right: 0 bottom: 2 left: 0).
	aFieldElement constraintsDo: [ :c | c horizontal matchParent ].

	aContainer
		addChild: aLabel;
		addChild: aFieldElement
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

{ #category : 'private - building' }
CFMaPresentation >> addSingleOptionDropdownUsing: aDescription [
	| aButton |
	aButton := GtMagritteBuilderUtility
		newSingleOptionDropdownMemento: self memento
		using: aDescription.
	self addShortcutsTo: aButton.
	self addFieldElement: aButton using: aDescription
]

{ #category : 'private - building' }
CFMaPresentation >> addStringFieldUsing: aDescription [
	| aStencil anInputElement |

	aStencil := aDescription blocStencil
		ifNil: [ GtMagritteStringEditorElementStencilBuilder new ].
	anInputElement := aStencil
		memento: self memento;
		description: aDescription;
		asElement.

	self addShortcutsTo: anInputElement using: aDescription.

	aDescription blocCompletion ifNotNil: [ :aCompletionStencil |
		| aCompletionStrategy |
		aCompletionStrategy := aCompletionStencil
			memento: self memento;
			description: aDescription;
			build.
		(GtCompletionController on: anInputElement strategy: aCompletionStrategy) install ].

	self addFieldElement: anInputElement using: aDescription.
	^ anInputElement
]

{ #category : 'api - building' }
CFMaPresentation >> build [
	identityAffordanceEmitted := false.
	fieldConfigurations removeAll.
	containersByGroup removeAll.
	ungroupedContainer := nil.
	self fieldContainerDo: [ :anElement | hostElement := anElement ].
	^ super build
]

{ #category : 'private - focus' }
CFMaPresentation >> configureTabStopFor: aFieldElement using: aDescription [
	"Keep GT/Brick's native focusable descendants. The field surface only
	participates when there are no focusable descendants of its own."
	aFieldElement focusability: BlFocusability after.
	self installFormNavigationOn: aFieldElement.
	^ aFieldElement
]

{ #category : 'private - groups' }
CFMaPresentation >> containerForDescription: aDescription [
	^ self containerForGroup: aDescription group
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

{ #category : 'defaults' }
CFMaPresentation >> defaultLabelAptitude [
	^ BrGlamorousLabelAptitude new
		foreground: (Color black alpha: 0.52);
		fontSize: 13
]

{ #category : 'configuration - fields' }
CFMaPresentation >> description: aDescription configure: aBlock [
	fieldConfigurationOverrides at: aDescription put: aBlock.
	fieldConfigurations removeKey: aDescription ifAbsent: [ ].
	^ self
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

{ #category : 'configuration - fields' }
CFMaPresentation >> fieldConfigurationFor: aDescription [
	^ fieldConfigurations
		at: aDescription
		ifAbsentPut: [
			| aConfiguration |
			aConfiguration := self newFieldConfiguration.
			aDescription configureField: aConfiguration.
			fieldConfigurationOverrides
				at: aDescription
				ifPresent: [ :aBlock | aBlock cull: aConfiguration ].
			aConfiguration ]
]

{ #category : 'private - groups' }
CFMaPresentation >> hostElement [
	^ hostElement
]

{ #category : 'initialization' }
CFMaPresentation >> initialize [
	super initialize.
	containersByGroup := Dictionary new.
	identityAffordanceEmitted := false.
	fieldConfigurationOverrides := Dictionary new.
	fieldConfigurations := Dictionary new
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

{ #category : 'configuration - fields' }
CFMaPresentation >> newFieldConfiguration [
	^ CFMaFieldConfiguration new
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

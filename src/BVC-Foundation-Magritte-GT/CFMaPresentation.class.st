"
I am Foundation's Magritte presentation. I participate directly in Magritte's visitor rendering path and own the composition of fields and groups for one form build.
"
Class {
	#name : 'CFMaPresentation',
	#superclass : 'GtMagritteElementBuilder',
	#instVars : [
		'hostElement',
		'presentationGroupsByGroup',
		'ungroupedPresentationGroup',
		'fieldConfigurationOverrides',
		'fieldConfigurations',
		'relationItemElementBlock'
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
	(self presentationGroupForDescription: aDescription)
		addContent: anElement
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
	self configureEnablementFor: aFieldElement label: aLabel using: aDescription.
	self addLabel: aLabel field: aFieldElement for: aDescription.
	^ aLabel
]

{ #category : 'private - composition' }
CFMaPresentation >> configureEnablementFor: aFieldElement label: aLabel using: aDescription [
	| anEnabledBlock |
	anEnabledBlock := aDescription enabledBlock.
	anEnabledBlock ifNil: [ ^ self ].

	self updateEnablementFor: aFieldElement label: aLabel using: aDescription.
	aFieldElement withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theField :aSink |
				self updateEnablementFor: theField label: aLabel using: aDescription ].
		self memento overallStatus observe: anElementSink ]
]

{ #category : 'private - composition' }
CFMaPresentation >> updateEnablementFor: aFieldElement label: aLabel using: aDescription [
	(aDescription enabledBlock cull: self memento model)
		ifTrue: [
			aFieldElement states removeState: BlElementState disabled.
			aLabel states removeState: BlElementState disabled ]
		ifFalse: [
			aFieldElement states addState: BlElementState disabled.
			aLabel states addState: BlElementState disabled ]
]

{ #category : 'private - composition' }
CFMaPresentation >> addCommentTooltipTo: anElement using: aDescription [
	| aTooltipAptitude |
	aTooltipAptitude := BrGlamorousWithExplicitTooltipAptitude new.
	aTooltipAptitude
		handle: [ BlElement new
			size: BrMenuConstants handleExtent * 2.0;
			geometry: BlCircleGeometry new;
			background: Color transparent;
			border: BlBorder empty;
			yourself ]
		content: [ self newCommentTooltipContentFor: aDescription ].
	aTooltipAptitude menuContainerDo: [ :aContainer |
		aContainer
			padding: BlInsets empty;
			beInSeparateCompositionLayer;
			aptitude: CFMaTooltipContainerAptitude new;
			effect: BlNullEffect new ].
	anElement addAptitude: aTooltipAptitude
]

{ #category : 'private - composition' }
CFMaPresentation >> newCommentTooltipContentFor: aDescription [
	| aText anEditor aSurface aShadowHost |
	aText := aDescription comment asRopedText
		foreground: self form theme tooltip foreground;
		fontSize: self form theme tooltip fontSize;
		yourself.
	aDescription isRequired ifTrue: [ aText append: (' (required)' asRopedText
		foreground: self form theme tooltip foreground;
		fontSize: self form theme tooltip fontSize;
		yourself) ].

	anEditor := BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithoutSelection;
		hFitContentLimited;
		vFitContent;
		constraintsDo: [ :c | c maxWidth: 226 ];
		padding: BlInsets empty;
		background: Color transparent;
		border: BlBorder empty;
		focusability: BlFocusability none;
		preventMouseEvents;
		text: aText;
		yourself.

	aSurface := BlElement new
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ];
		padding: (BlInsets top: 8 left: 12 bottom: 8 right: 12);
		geometry: (BlRoundedRectangleGeometry cornerRadius: self form theme tooltip cornerRadius);
		beInSeparateCompositionLayer;
		addAptitude: CFGlassSurfaceAptitude new;
		addAptitude: (BrLazyStyleCommonAptitude new
			default: [ :aStyle |
				aStyle border: (BlBorder
					paint: (aSurface theme tooltip borderColor
						blocResolveColorForTheme: aSurface theme)
					width: 1) ]);
		addChild: anEditor;
		yourself.

	aShadowHost := BlElement new
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ];
		geometry: (BlRoundedRectangleGeometry cornerRadius: self form theme tooltip cornerRadius);
		background: Color transparent;
		border: BlBorder empty;
		addAptitude: (BrShadowAptitude new
			color: (self form theme tooltip shadowColor blocResolveColorForTheme: self form theme);
			width: self form theme tooltip shadowWidth;
			offset: self form theme tooltip shadowOffset;
			yourself);
		addChild: aSurface;
		yourself.

	^ aShadowHost
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
	| aPresentationGroup |
	aLabel margin: (BlInsets top: 3 right: 0 bottom: 2 left: 0).
	aFieldElement constraintsDo: [ :c | c horizontal matchParent ].

	aPresentationGroup := self presentationGroupForDescription: aDescription.
	aPresentationGroup
		addContent: aLabel;
		addContent: aFieldElement
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
	fieldConfigurations removeAll.
	presentationGroupsByGroup removeAll.
	ungroupedPresentationGroup := nil.
	self fieldContainerDo: [ :anElement | hostElement := anElement ].
	self prepareHostElement.
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
CFMaPresentation >> presentationGroupForDescription: aDescription [
	^ self presentationGroupForGroup: aDescription group
]

{ #category : 'private - groups' }
CFMaPresentation >> presentationGroupForGroup: aGroup [
	aGroup ifNil: [
		^ ungroupedPresentationGroup ifNil: [
			ungroupedPresentationGroup := self newPresentationGroupNamed: nil ] ].

	^ presentationGroupsByGroup
		at: aGroup
		ifAbsentPut: [ self newPresentationGroupNamed: aGroup ]
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
	presentationGroupsByGroup := Dictionary new.
	fieldConfigurationOverrides := Dictionary new.
	fieldConfigurations := Dictionary new
]


{ #category : 'private - focus' }
CFMaPresentation >> installFormNavigationOn: anElement [
	^ self
		installFormNavigationOn: anElement
		forwardCombination: (BlKeyCombination tab or: BlKeyCombination enter)
]

{ #category : 'private - focus' }
CFMaPresentation >> installFormNavigationOn: anElement forwardCombination: aForwardCombination [
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
			combination: aForwardCombination;
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

{ #category : 'private - groups' }
CFMaPresentation >> newPresentationGroupNamed: aGroup [
	| aPresentationGroup |
	aPresentationGroup := CFMaPresentationGroupElement new
		group: aGroup;
		yourself.
	hostElement addChild: aPresentationGroup.
	^ aPresentationGroup
]

{ #category : 'private - building' }
CFMaPresentation >> prepareHostElement [
]

{ #category : 'private - composition' }
CFMaPresentation >> newPresentationHost [
	^ CFMaPresentationHostElement new
]

{ #category : 'private - composition' }
CFMaPresentation >> buildPresentationForMemento: aMemento in: aHostElement configure: aConfigurationBlock [
	| aPresentation |
	aPresentation := aMemento magritteDescription blocPresentationStencil
		memento: aMemento;
		build.
	aPresentation
		memento: aMemento;
		form: aHostElement.
	aConfigurationBlock cull: aPresentation.
	aPresentation build.
	^ aPresentation
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

{ #category : 'configuration - relations' }
CFMaPresentation >> relationItemElementDo: aBlock [
	"Configure a consumer callback for relation item elements exposed by a concrete Foundation presentation. The presentation remains responsible for rendering; consumers may add interaction to the rendered item."
	relationItemElementBlock := aBlock
]

{ #category : 'private - relations' }
CFMaPresentation >> configureRelationItemElement: anElement object: anObject description: aDescription [
	relationItemElementBlock ifNotNil: [ :aBlock |
		aBlock
			value: anElement
			value: anObject
			value: aDescription
			value: self memento ].
	^ anElement
]


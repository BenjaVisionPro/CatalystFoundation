Class {
	#name : 'CFMaBuilderUtility',
	#superclass : 'GtMagritteBuilderUtility',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'elements' }
CFMaBuilderUtility class >> newFieldLabelUsing: aDescription [
	| aText labelAptitude |
	aText := aDescription label asRopedText.

	labelAptitude := aDescription labelAptitude
			ifNil: [ BrGlamorousLabelAptitude new
				foreground: (Color black alpha: 0.28) ]
			ifNotNil: #value.

	^ BrLabel new
		id: (GtMagritteFieldLabelId new description: aDescription);
		text: aText;
		aptitude: labelAptitude;
		hMatchParent;
		fitContent;
		margin: (BlInsets top: 0 right: 0 bottom: 4 left: 12);
		when: BlClickEvent
			do: [ :anEvent |
				anEvent modifiers isAlt
					ifTrue: [ anEvent consumed: true.
						anEvent target phlow spawnObject: aDescription ] ]
]

{ #category : 'elements' }
CFMaBuilderUtility class >> newFieldLabelWithSpace: aSpaceNumber using: aDescription [
	^ self newFieldLabelUsing: aDescription
]

{ #category : 'elements' }
CFMaBuilderUtility class >> newFormContainerFor: aMemento [
	^ BrVerticalPane new
		in: [ :aPane |
			aPane magritte
				beFieldContainer;
				beToolbarContainer ];
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 12);
		cellSpacing: 8;
		background: (Color black alpha: 0.05);
		yourself
]

{ #category : 'elements' }
CFMaBuilderUtility class >> newGroupLabelUsing: aGroupName [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.28));
		text: aGroupName asString asUppercase;
		hMatchParent;
		fitContent;
		margin: (BlInsets top: 2 right: 0 bottom: 6 left: 0);
		yourself
]

{ #category : 'api - ui' }
CFMaBuilderUtility class >> newFlowListMemento: aMemento using: aDescription [
	| aContainer aList isEditable |
	isEditable := aDescription definitive not
		and: [ aDescription newItemStencil isNotNil ].

	aContainer := BrVerticalPane new
		matchParent;
		vFitContent;
		cellSpacing: 8;
		yourself.

	aList := BrSimpleList new.
	aList
		matchParent;
		itemType: [ :anItemTypeFactory :anItemObject :anItemIndex |
			anItemTypeFactory default ];
		itemStencil: self newPhlowListItemStencil;
		itemDataBinder: self newPhlowListItemDataBinder;
		addEventHandler: (GtPhlowListToSelectHandler new
			transformation: GtPhlowSendTransformation default).
	aList constraintsDo: [ :c | c padding: (BlInsets top: 10 bottom: 10) ].

	aContainer addChild: aList.

	isEditable
		ifTrue: [ | anAddElement |
			anAddElement := CFMaAddItemViewModel new
				memento: aMemento;
				description: aDescription;
				stencil: aDescription newItemStencil;
				asElement.
			aContainer addChild: anAddElement ].

	aContainer withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theContainer :aSink |
				self
					onFlowList: aList
					sinkUpdate: aSink
					memento: aMemento
					description: aDescription ].
		(aMemento readObservableValueUsing: aDescription)
			observe: anElementSink ].

	^ aContainer
]


{ #category : 'private - support' }
CFMaBuilderUtility class >> newPhlowListItemDataBinder [
	^ GtPhlowSimpleListErrorHandlingItemDataBinder new
		dataBinder: (GtPhlowSimpleListItemComputationDataBinder new
			dataBinder: GtPhlowListTextDataBinder new;
			itemComputation: [ :eachItem :eachIndex | eachItem ];
			yourself);
		yourself
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> newPhlowListItemStencil [
	^ GtPhlowListItemElementWithSelectionDecorator new
		stencilBuilder: (GtPhlowSimpleListErrorHandlingItemElementStencilBuilder new
			stencilBuilder: GtPhlowListTextElementStencilBuilder new;
			cellSpacing: (BlInsets left: 10);
			yourself);
		yourself
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> onFlowList: aListElement sinkUpdate: aSink memento: aMemento description: aDescription [
	| aModels |
	aModels := aSink value currentValue ifNil: [ #() ].
	^ aListElement items: aModels
]


{ #category : 'api - ui' }
CFMaBuilderUtility class >> newToOneListMemento: aMemento using: aDescription [
	| aContainer aList anActionContainer isModifiable canAdd anAddElement aRemoveButton |
	isModifiable := true.
	canAdd := aDescription newItemStencil isNotNil.

	aContainer := BrVerticalPane new
		matchParent;
		vFitContent;
		cellSpacing: 8;
		yourself.

	aList := BrSimpleList new.
	aList
		matchParent;
		itemType: [ :anItemTypeFactory :anItemObject :anItemIndex |
			anItemTypeFactory default ];
		itemStencil: self newPhlowListItemStencil;
		itemDataBinder: self newPhlowListItemDataBinder;
		addEventHandler: (GtPhlowListToSelectHandler new
			transformation: GtPhlowSendTransformation default).
	aList constraintsDo: [ :c | c padding: (BlInsets top: 10 bottom: 10) ].

	aContainer addChild: aList.

	(isModifiable or: [ canAdd ]) ifTrue: [
		anActionContainer := BrHorizontalPane new
			fitContent;
			cellSpacing: 8;
			yourself.

		canAdd ifTrue: [
			anAddElement := CFMaToOneAddItemViewModel new
				memento: aMemento;
				description: aDescription;
				stencil: aDescription newItemStencil;
				asElement.
			anActionContainer addChild: anAddElement ].

		isModifiable ifTrue: [
			aRemoveButton := self newToOneRemoveButtonMemento: aMemento using: aDescription.
			anActionContainer addChild: aRemoveButton ].

		aContainer addChild: anActionContainer ].

	aContainer withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theContainer :aSink |
				self
					onToOneList: aList
					sinkUpdate: aSink
					memento: aMemento
					description: aDescription.
				isModifiable ifTrue: [
					self
						updateToOneRemoveButton: aRemoveButton
						sinkUpdate: aSink ] ].
		(aMemento readObservableValueUsing: aDescription)
			observe: anElementSink ].

	^ aContainer
]

{ #category : 'api - ui' }
CFMaBuilderUtility class >> newEmbeddedToOneMemento: aMemento using: aDescription [
	| aContainer aFrame anActionContainer isModifiable canAdd anAddElement aRemoveButton |
	isModifiable := true.
	canAdd := aDescription newItemStencil isNotNil.

	aContainer := BrVerticalPane new
		matchParent;
		vFitContent;
		cellSpacing: 8;
		yourself.

	aFrame := BrFrame new
		hMatchParent;
		vFitContent;
		yourself.
	aContainer addChild: aFrame.

	(isModifiable or: [ canAdd ]) ifTrue: [
		anActionContainer := BrHorizontalPane new
			fitContent;
			cellSpacing: 8;
			yourself.

		canAdd ifTrue: [
			anAddElement := CFMaToOneAddItemViewModel new
				memento: aMemento;
				description: aDescription;
				stencil: aDescription newItemStencil;
				asElement.
			anActionContainer addChild: anAddElement ].

		isModifiable ifTrue: [
			aRemoveButton := self newToOneRemoveButtonMemento: aMemento using: aDescription.
			anActionContainer addChild: aRemoveButton ].

		aContainer addChild: anActionContainer ].

	aContainer withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theContainer :aSink |
				self
					onEmbeddedToOneFrame: aFrame
					sinkUpdate: aSink.
				isModifiable ifTrue: [
					self
						updateToOneRemoveButton: aRemoveButton
						sinkUpdate: aSink ] ].
		(aMemento readObservableValueUsing: aDescription)
			observe: anElementSink ].

	^ aContainer
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> onToOneList: aListElement sinkUpdate: aSink memento: aMemento description: aDescription [
	| anObject aModels |
	anObject := aSink value currentValue.
	aModels := anObject ifNil: [ #() ] ifNotNil: [ { anObject } ].
	^ aListElement items: aModels
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> onEmbeddedToOneFrame: aFrame sinkUpdate: aSink [
	| anObject anElement |
	anObject := aSink value currentValue.
	aFrame removeChildren.
	anObject ifNil: [ ^ self ].

	anElement := anObject asGtMagritteViewModel asElement.
	aFrame addChild: anElement
]

{ #category : 'private - instance creation' }
CFMaBuilderUtility class >> newToOneRemoveButtonMemento: aMemento using: aDescription [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude;
		icon: BrGlamorousVectorIcons remove;
		label: 'Remove';
		action: [ :anElement |
			GtMagritteBuilderUtility
				write: nil
				using: aDescription
				memento: aMemento
				element: anElement ];
		disable;
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> updateToOneRemoveButton: aButton sinkUpdate: aSink [
	| anObject |
	anObject := aSink value currentValue.
	anObject
		ifNil: [ aButton disable ]
		ifNotNil: [ aButton enable ]
]

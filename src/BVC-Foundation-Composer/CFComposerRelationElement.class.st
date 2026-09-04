Class {
	#name : 'CFComposerRelationElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'memento',
		'description',
		'formController',
		'itemMementos',
		'itemElements'
	],
	#category : 'BVC-Foundation-Composer',
	#package : 'BVC-Foundation-Composer'
}

{ #category : 'instance creation' }
CFComposerRelationElement class >> memento: aMemento description: aDescription formController: aFormController [
	^ self new
		memento: aMemento;
		description: aDescription;
		formController: aFormController;
		build;
		yourself
]

{ #category : 'private - building' }
CFComposerRelationElement >> build [
	self synchronizeItems: self relationItems.
	self installRelationObserver.
	self installDropHandler
]

{ #category : 'accessing' }
CFComposerRelationElement >> description [
	^ description
]

{ #category : 'accessing' }
CFComposerRelationElement >> description: aDescription [
	description := aDescription
]

{ #category : 'accessing' }
CFComposerRelationElement >> formController [
	^ formController
]

{ #category : 'accessing' }
CFComposerRelationElement >> formController: aComposerFormController [
	formController := aComposerFormController
]

{ #category : 'initialization' }
CFComposerRelationElement >> initialize [
	super initialize.
	itemMementos := OrderedCollection new.
	itemElements := OrderedCollection new.
	self
		hMatchParent;
		vFitContent;
		cellSpacing: 8;
		padding: BlInsets empty;
		background: Color transparent;
		border: BlBorder empty
]

{ #category : 'accessing' }
CFComposerRelationElement >> memento [
	^ memento
]

{ #category : 'accessing' }
CFComposerRelationElement >> memento: aMemento [
	memento := aMemento
]

{ #category : 'private - building' }
CFComposerRelationElement >> relationItems [
	| aValue |
	aValue := memento readUsing: description.
	aValue ifNil: [ ^ #() ].
	(description isKindOf: MAToManyRelationDescription) ifTrue: [
		^ aValue asArray ].
	^ { aValue }
]

{ #category : 'private - building' }
CFComposerRelationElement >> installRelationObserver [
	self withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anElement :aSink |
				anElement synchronizeItemsFromValue: aSink value currentValue ].
		(memento readObservableValueUsing: description) observe: anElementSink ]
]

{ #category : 'private - building' }
CFComposerRelationElement >> newItemElementFor: aMemento [
	| aChildViewModel aCard anElement aHandle |
	aChildViewModel := CFComposerEditorViewModel
		forMemento: aMemento
		formController: formController.
	aCard := aChildViewModel asElement
		hMatchParent;
		vFitContent;
		yourself.
	anElement := BrFrame new
		hMatchParent;
		vFitContent;
		addChild: aCard;
		yourself.
	aHandle := BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.28));
		text: '⠿';
		padding: (BlInsets all: 5);
		constraintsDo: [ :c |
			c ignoreByLayout.
			c ignored horizontal alignRight.
			c ignored vertical alignBottom ];
		margin: (BlInsets bottom: 2 right: 4);
		yourself.
	aHandle addEventHandler: (BlDragHandler new
		liftItem: [ :aSourceElement |
			BlDragItem new
				sourceElement: aSourceElement;
				domainObject: aMemento model;
				stencil: [ :aDragItem |
					BrLabel new
						text: aDragItem domainObject printString;
						padding: (BlInsets all: 8);
						yourself ] ]).
	anElement addChild: aHandle.
	^ anElement
]

{ #category : 'private - drag and drop' }
CFComposerRelationElement >> installDropHandler [
	self addEventHandler: (BlDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea |
			aDragItem sourceElement parent
				ifNil: [ true ]
				ifNotNil: [ :anItemElement | anItemElement parent ~~ aDropArea ] ];
		acceptDomainObjectsSuchThat: [ :anObject | self canAcceptDroppedObject: anObject ];
		whenDroppedDo: [ :anEvent |
			self addDroppedObjects: (anEvent items collect: #domainObject) ])
]

{ #category : 'private - drag and drop' }
CFComposerRelationElement >> canAcceptDroppedObject: anObject [
	description isReadOnly ifTrue: [ ^ false ].
	^ [ description validate: (self valueByAddingDroppedObjects: { anObject }) . true ]
		on: MAValidationError
		do: [ :anError | false ]
]

{ #category : 'private - drag and drop' }
CFComposerRelationElement >> addDroppedObjects: aCollection [
	| aNewValue |
	aCollection ifEmpty: [ ^ self ].
	aNewValue := self valueByAddingDroppedObjects: aCollection.
	GtMagritteBuilderUtility
		write: aNewValue
		using: description
		memento: memento
		element: self
]

{ #category : 'private - drag and drop' }
CFComposerRelationElement >> valueByAddingDroppedObjects: aCollection [
	| currentValue |
	currentValue := memento readUsing: description.
	(description isKindOf: MAToManyRelationDescription) ifFalse: [
		^ aCollection first ].
	currentValue ifNil: [ currentValue := #() ].
	^ aCollection inject: currentValue into: [ :aValue :each |
		aValue copyWith: each ]
]

{ #category : 'private - updating' }
CFComposerRelationElement >> synchronizeItems: desiredItems [
	| unmatchedMementos unmatchedElements newMementos newElements createdElements |
	unmatchedMementos := itemMementos copy.
	unmatchedElements := itemElements copy.
	newMementos := OrderedCollection new.
	newElements := OrderedCollection new.
	createdElements := OrderedCollection new.
	desiredItems do: [ :anItem |
		| index aMemento anElement |
		index := unmatchedMementos findFirst: [ :each | each model == anItem ].
		index = 0
			ifTrue: [
				aMemento := formController
					registerMemento: (GtMagritteMemento model: anItem)
					below: memento.
				anElement := self newItemElementFor: aMemento.
				createdElements add: anElement ]
			ifFalse: [
				aMemento := unmatchedMementos removeAt: index.
				anElement := unmatchedElements removeAt: index ].
		newMementos add: aMemento.
		newElements add: anElement ].
	unmatchedMementos do: [ :each |
		formController unregisterMementoAndDescendants: each ].
	(newElements asArray = itemElements asArray) ifTrue: [
		itemMementos := newMementos.
		^ self ].
	self replaceItemsWith: newElements created: createdElements.
	itemMementos := newMementos.
	itemElements := newElements
]

{ #category : 'private - updating' }
CFComposerRelationElement >> synchronizeItemsFromValue: aValue [
	aValue ifNil: [ ^ self synchronizeItems: #() ].
	(description isKindOf: MAToManyRelationDescription)
		ifTrue: [ self synchronizeItems: aValue asArray ]
		ifFalse: [ self synchronizeItems: { aValue } ]
]

{ #category : 'private - updating' }
CFComposerRelationElement >> replaceItemsWith: newElements created: createdElements [
	| existingElements insertedElement insertionIndex |
	existingElements := itemElements asArray.
	newElements isEmpty ifTrue: [
		self removeChildren.
		^ self ].
	existingElements isEmpty ifTrue: [
		createdElements size = 1
			ifTrue: [
				insertedElement := createdElements first.
				insertedElement opacity: 0.0.
				self addChild: insertedElement.
				insertedElement isAttachedToSceneGraph ifTrue: [
					(insertedElement motion
						duration: 180 milliSeconds;
						riseAndFadeIn) ] ]
			ifFalse: [ self addChildren: newElements ].
		^ self ].
	(createdElements size = 1 and: [ existingElements notEmpty and: [
		self isAttachedToSceneGraph and: [
			insertedElement := createdElements first.
			(existingElements = (newElements copyWithout: insertedElement)) ]]])
		ifTrue: [
			insertionIndex := newElements indexOf: insertedElement.
			(CFMotionLayoutTransaction on: self)
				affecting: existingElements;
				insert: insertedElement into: self at: insertionIndex;
				fadeIn: insertedElement;
				play ]
		ifFalse: [
			self removeChildren.
			self addChildren: newElements ]
]

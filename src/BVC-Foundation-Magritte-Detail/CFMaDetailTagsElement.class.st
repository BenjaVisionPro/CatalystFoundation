Class {
	#name : 'CFMaDetailTagsElement',
	#superclass : 'BlElement',
	#instVars : [
		'description',
		'memento',
		'values',
		'selectedTag',
		'activeEditor',
		'editingIndex',
		'editingExisting',
		'addButton'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailTagsElement >> initialize [
	super initialize.
	values := #().
	editingExisting := false.
	self
		layout: (BlFlowLayout horizontal
			horizontalAlignment: BlElementAlignment horizontal end;
			yourself);
		background: Color transparent;
		padding: BlInsets empty;
		constraintsDo: [ :c |
			c horizontal fitContentLimited.
			c vertical fitContent ].
	addButton := self newAddButton.
]

{ #category : 'accessing' }
CFMaDetailTagsElement >> description: aDescription memento: aMemento [
	description := aDescription.
	memento := aMemento.
	self observeValue.
]

{ #category : 'private - model' }
CFMaDetailTagsElement >> observeValue [
	self withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theElement :aSink |
				theElement reconcileWith: aSink value currentValue ].
		(memento readObservableValueUsing: description) observe: anElementSink ]
]

{ #category : 'private - model' }
CFMaDetailTagsElement >> reconcileWith: aCollection [
	| incomingValues |
	activeEditor ifNotNil: [ ^ self ].
	incomingValues := aCollection ifNil: [ #() ].
	values = incomingValues ifTrue: [ ^ self ].
	values := incomingValues.
	selectedTag := nil.
	self removeChildren.
	values do: [ :each | self addChild: (self newPillFor: each) ].
	description isDefinitive ifFalse: [ self addChild: addButton ]
]

{ #category : 'private - instance creation' }
CFMaDetailTagsElement >> newAddButton [
	| aButton anIndicator |
	anIndicator := CFMaDetailAddIconElement size: 12 @ 12.
	aButton := BrButton new
		aptitude: BrGlamorousButtonLayoutAptitude new;
		background: Color transparent;
		border: BlBorder empty;
		padding: (BlInsets all: 4);
		margin: (BlInsets top: 2 right: 0 bottom: 2 left: 0);
		fitContent;
		constraintsDo: [ :c | c flow vertical alignCenter ];
		addChild: anIndicator;
		when: BlMouseEnterEvent do: [ :anEvent |
			anIndicator hovered: true ];
		when: BlMouseLeaveEvent do: [ :anEvent |
			anIndicator hovered: false ];
		action: [ :aButton | self beginInsertionAtEnd ];
		yourself.
	^ aButton
]

{ #category : 'private - instance creation' }
CFMaDetailTagsElement >> newPillFor: aValue [
	| aPill |
	aPill := CFMaDetailTagElement new
		value: aValue;
		text: (description reference toString: aValue);
		selectedBlock: [ :aTag | self selectTag: aTag ];
		when: BrEditorAcceptWish do: [ :aWish |
			self acceptEditionOfTag: aPill text: aWish text ];
		yourself.
	description isDefinitive ifFalse: [
		aPill
			addShortcut: (BlShortcutWithAction new
				name: 'Remove selected tag';
				combination: BlKeyCombination delete;
				overrideChildren: true;
				action: [ :anEvent :aShortcut |
					anEvent consumed: true.
					self removeSelectedTag ]);
			addShortcut: (BlShortcutWithAction new
				name: 'Remove selected tag';
				combination: BlKeyCombination builder backspace build;
				overrideChildren: true;
				action: [ :anEvent :aShortcut |
					anEvent consumed: true.
					self removeSelectedTag ]);
			addShortcut: (BlShortcutWithAction new
				name: 'Edit selected tag';
				combination: BlKeyCombination enter;
				overrideChildren: true;
				action: [ :anEvent :aShortcut |
					anEvent consumed: true.
					self beginEditingTag: aPill ]) ].
	^ aPill
]

{ #category : 'private - editing' }
CFMaDetailTagsElement >> acceptEditionOfTag: aTag text: aText [
	| anIndex aString newValues newValue |
	description isDefinitive ifTrue: [ ^ self ].
	anIndex := self children indexOf: aTag.
	anIndex = 0 ifTrue: [ ^ self ].
	aString := aText asString trimBoth.
	newValues := values asOrderedCollection.
	aString
		ifEmpty: [ newValues removeAt: anIndex ]
		ifNotEmpty: [
			newValue := description reference fromString: aString.
			newValues at: anIndex put: newValue ].
	selectedTag := nil.
	self writeValues: newValues
]

{ #category : 'selection' }
CFMaDetailTagsElement >> selectTag: aTag [
	activeEditor ifNotNil: [ self commitActiveEditor ].
	selectedTag ifNotNil: [ :anOldTag |
		anOldTag == aTag ifFalse: [ anOldTag beUnselected ] ].
	selectedTag := aTag.
	selectedTag beSelected.
	selectedTag requestFocus
]

{ #category : 'private - editing' }
CFMaDetailTagsElement >> beginEditingTag: aTag [
	description isDefinitive ifTrue: [ ^ self ].
	activeEditor ifNotNil: [ self commitActiveEditor ].
	editingIndex := self children indexOf: aTag.
	editingExisting := true.
	selectedTag := nil.
	activeEditor := self newEditorWithText: (description reference toString: aTag value).
	self removeChild: aTag.
	self addChild: activeEditor at: editingIndex.
	self applyThemeToEditor: activeEditor.
	activeEditor switchToEditor.
	activeEditor requestFocus
]

{ #category : 'private - editing' }
CFMaDetailTagsElement >> beginInsertionAtEnd [
	description isDefinitive ifTrue: [ ^ self ].
	activeEditor ifNotNil: [ self commitActiveEditor ].
	selectedTag ifNotNil: [
		selectedTag beUnselected.
		selectedTag := nil ].
	editingIndex := values size + 1.
	editingExisting := false.
	activeEditor := self newEditorWithText: ''.
	self addChild: activeEditor before: addButton.
	self applyThemeToEditor: activeEditor.
	activeEditor
		requestFocus;
		switchToEditor.
	activeEditor navigator
		moveTo: 0;
		apply
]

{ #category : 'private - editing' }
CFMaDetailTagsElement >> beginInsertionAtPoint: aPoint [
	| anIndex |
	description isDefinitive ifTrue: [ ^ self ].
	activeEditor ifNotNil: [ self commitActiveEditor ].
	selectedTag ifNotNil: [
		selectedTag beUnselected.
		selectedTag := nil ].
	anIndex := self insertionIndexAt: aPoint.
	editingIndex := anIndex.
	editingExisting := false.
	activeEditor := self newEditorWithText: ''.
	self addChild: activeEditor at: anIndex.
	self applyThemeToEditor: activeEditor.
	activeEditor switchToEditor.
	activeEditor requestFocus
]

{ #category : 'private - editing' }
CFMaDetailTagsElement >> newEditorWithText: aString [
	| anEditor |
	anEditor := CFEditableLabel new
		aptitude: (CFMaDetailTagAptitude new
			glamorousRegularFont;
			glamorousRegularSmallSize);
		text: aString;
		fitContent;
		padding: (BlInsets top: 2 right: 8 bottom: 2 left: 8);
		margin: (BlInsets top: 2 right: 4 bottom: 2 left: 0);
		background: Color transparent;
		border: BlBorder empty;
		constraintsDo: [ :c |
			c flow vertical alignCenter ];
		yourself.
	anEditor
		when: BlElementThemeChanged do: [ :anEvent | self applyThemeToEditor: anEditor ];
		when: BrEditorAcceptWish do: [ :aWish | self commitActiveEditor ];
		when: BrEditorCancelWish do: [ :aWish | self cancelActiveEditor ].
	self installCompletionOn: anEditor.
	^ anEditor
]

{ #category : 'private - completion' }
CFMaDetailTagsElement >> installCompletionOn: anEditor [
	description reference blocCompletion ifNotNil: [ :aCompletionStencil |
		| aCompletionStrategy |
		aCompletionStrategy := aCompletionStencil
			memento: memento;
			description: description reference;
			build.
		(GtCompletionController on: anEditor strategy: aCompletionStrategy) install ]
]

{ #category : 'private - editing' }
CFMaDetailTagsElement >> commitActiveEditor [
	| aString newValues newValue aPill anEditor anIndex |
	activeEditor ifNil: [ ^ self ].
	anEditor := activeEditor.
	anIndex := editingIndex.
	aString := anEditor text asString trimBoth.
	newValues := values asOrderedCollection.

	editingExisting
		ifTrue: [
			aString
				ifEmpty: [ newValues removeAt: anIndex ]
				ifNotEmpty: [
					newValue := description reference fromString: aString.
					newValues at: anIndex put: newValue ] ]
		ifFalse: [
			aString ifNotEmpty: [
				newValue := description reference fromString: aString.
				anIndex > newValues size
					ifTrue: [ newValues add: newValue ]
					ifFalse: [ newValues add: newValue beforeIndex: anIndex ] ] ].

	aString
		ifEmpty: [
			anEditor parent ifNotNil: [ anEditor removeFromParent ] ]
		ifNotEmpty: [
			aPill := self newPillFor: newValue.
			self addChild: aPill at: anIndex.
			anEditor parent ifNotNil: [ anEditor removeFromParent ] ].

	activeEditor := nil.
	editingIndex := nil.
	editingExisting := false.
	values := self collectionFrom: newValues.
	self writeCollection: values
]

{ #category : 'private - editing' }
CFMaDetailTagsElement >> cancelActiveEditor [
	activeEditor ifNil: [ ^ self ].
	self finishEditing.
	self reconcileWith: values
]

{ #category : 'private - editing' }
CFMaDetailTagsElement >> finishEditing [
	activeEditor ifNotNil: [
		activeEditor parent ifNotNil: [ activeEditor removeFromParent ] ].
	activeEditor := nil.
	editingIndex := nil.
	editingExisting := false
]

{ #category : 'private - model' }
CFMaDetailTagsElement >> collectionFrom: someValues [
	^ values
		ifNil: [ someValues asArray ]
		ifNotNil: [
			[ values species withAll: someValues ]
				on: Error
				do: [ :anError | someValues asArray ] ]
]

{ #category : 'private - model' }
CFMaDetailTagsElement >> writeCollection: aCollection [
	GtMagritteBuilderUtility
		write: aCollection
		using: description
		memento: memento
		element: self
]

{ #category : 'private - model' }
CFMaDetailTagsElement >> writeValues: someValues [
	self writeCollection: (self collectionFrom: someValues)
]

{ #category : 'private - interaction' }
CFMaDetailTagsElement >> removeSelectedTag [
	| anIndex newValues |
	description isDefinitive ifTrue: [ ^ self ].
	selectedTag ifNil: [ ^ self ].
	anIndex := self children indexOf: selectedTag.
	newValues := values asOrderedCollection.
	newValues removeAt: anIndex.
	selectedTag := nil.
	self writeValues: newValues
]

{ #category : 'private - layout' }
CFMaDetailTagsElement >> insertionIndexAt: aPoint [
	| laidOutChildren nearestLineDistance lineChildren |
	laidOutChildren := self children select: [ :each | each ~~ activeEditor ].
	laidOutChildren ifEmpty: [ ^ 1 ].

	nearestLineDistance := nil.
	lineChildren := OrderedCollection new.
	laidOutChildren do: [ :each |
		| bounds distance |
		bounds := (each bounds inParent: self) asRectangle.
		distance := aPoint y < bounds top
			ifTrue: [ bounds top - aPoint y ]
			ifFalse: [
				aPoint y > bounds bottom
					ifTrue: [ aPoint y - bounds bottom ]
					ifFalse: [ 0 ] ].
		(nearestLineDistance isNil or: [ distance < nearestLineDistance ]) ifTrue: [
			nearestLineDistance := distance.
			lineChildren removeAll.
			lineChildren add: each ]
		ifFalse: [
			distance = nearestLineDistance ifTrue: [ lineChildren add: each ] ] ].

	lineChildren do: [ :each |
		| bounds |
		bounds := (each bounds inParent: self) asRectangle.
		aPoint x < bounds center x ifTrue: [
			^ self children indexOf: each ] ].
	^ (self children indexOf: lineChildren last) + 1
]


{ #category : 'layout' }
CFMaDetailTagsElement >> supportsBaseline [
	^ self children accountedByLayout isNotEmpty
]

{ #category : 'layout' }
CFMaDetailTagsElement >> baselineOffset [
	| aChild |
	aChild := self children accountedByLayout
		ifEmpty: [ ^ 0 ]
		ifNotEmpty: [ :someChildren | someChildren first ].
	aChild supportsBaseline ifFalse: [ ^ 0 ].
	^ aChild margin top + aChild baselineOffset
]


{ #category : #'theme - applying' }
CFMaDetailTagsElement >> applyThemeToEditor: anEditor [
	| aTheme aFocusedBorderColor |
	aTheme := anEditor theme.
	aFocusedBorderColor := aTheme interaction focusedBorderColor blocResolveColorForTheme: aTheme.
	anEditor
		background: aTheme controls tagEditorBackground;
		border: (BlBorder paint: aFocusedBorderColor width: 1)
]

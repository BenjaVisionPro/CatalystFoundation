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
		'editingExisting'
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
		layout: BlFlowLayout horizontal;
		hMatchParent;
		vFitContent;
		padding: BlInsets empty;
		when: BlClickEvent do: [ :anEvent |
			anEvent target == self ifTrue: [
				self beginInsertionAtPoint: (self globalPointToLocal: anEvent position) ] ].
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
	activeEditor ifNotNil: [ ^ self ].
	values := aCollection ifNil: [ #() ].
	selectedTag := nil.
	self removeChildren.
	values do: [ :each | self addChild: (self newPillFor: each) ]
]

{ #category : 'private - instance creation' }
CFMaDetailTagsElement >> newPillFor: aValue [
	| aPill |
	aPill := CFMaDetailTagElement new
		value: aValue;
		text: (description reference toString: aValue);
		selectedBlock: [ :aTag | self selectTag: aTag ];
		yourself.
	description isDefinitive ifFalse: [
		aPill
			whenKey: BlKeyCombination delete labelDo: [ :anEvent :aShortcut |
				self removeSelectedTag ];
			whenKey: BlKeyCombination backspace labelDo: [ :anEvent :aShortcut |
				self removeSelectedTag ];
			whenKey: BlKeyCombination enter labelDo: [ :anEvent :aShortcut |
				self beginEditingTag: aPill ] ].
	^ aPill
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
	activeEditor requestFocus.
	activeEditor switchToEditor
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
	activeEditor requestFocus.
	activeEditor switchToEditor
]

{ #category : 'private - editing' }
CFMaDetailTagsElement >> newEditorWithText: aString [
	| anEditor |
	anEditor := CFEditableLabel new
		aptitude: BrGlamorousEditableLabelAptitude new glamorousRegularFontAndSize;
		text: aString;
		fitContent;
		padding: (BlInsets top: 3 right: 8 bottom: 3 left: 8);
		margin: (BlInsets top: 2 right: 4 bottom: 2 left: 0);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
		background: (Color white alpha: 0.9);
		border: (BlBorder paint: CFMaDetailColours highlight width: 1);
		constraintsDo: [ :c |
			c flow vertical alignCenter.
			c minWidth: 36 ];
		yourself.
	anEditor
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
	| aString newValues newValue |
	activeEditor ifNil: [ ^ self ].
	aString := activeEditor text asString trimBoth.
	newValues := values asOrderedCollection.

	editingExisting
		ifTrue: [
			aString
				ifEmpty: [ newValues removeAt: editingIndex ]
				ifNotEmpty: [
					newValue := description reference fromString: aString.
					newValues at: editingIndex put: newValue ] ]
		ifFalse: [
			aString ifNotEmpty: [
				newValue := description reference fromString: aString.
				newValues add: newValue beforeIndex: editingIndex ] ].

	self finishEditing.
	self writeValues: newValues
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
CFMaDetailTagsElement >> writeValues: someValues [
	| aCollection |
	aCollection := values
		ifNil: [ someValues asArray ]
		ifNotNil: [
			[ values species withAll: someValues ]
				on: Error
				do: [ :anError | someValues asArray ] ].
	GtMagritteBuilderUtility
		write: aCollection
		using: description
		memento: memento
		element: self
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
		bounds := each bounds inParent asRectangle.
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
		bounds := each bounds inParent asRectangle.
		aPoint x < bounds center x ifTrue: [
			^ self children indexOf: each ] ].
	^ (self children indexOf: lineChildren last) + 1
]

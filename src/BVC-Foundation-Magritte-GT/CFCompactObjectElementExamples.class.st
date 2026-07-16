Class {
	#name : 'CFCompactObjectElementExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples' }
CFCompactObjectElementExamples >> compactObject [
	<gtExample>
	| anObject anElement |
	anObject := CFMagritteEditorExample exampleDefault.
	anElement := CFCompactObjectStencil new
		object: anObject;
		create.

	self assert: anElement displayedObject == anObject.
	self assert: anElement titleText equals: 'Editor example'.
	self assert: anElement iconContainer children size equals: 1.
	^ anElement
]

{ #category : 'examples' }
CFCompactObjectElementExamples >> compactObjectUsesMementoValue [
	<gtExample>
	| anObject aMemento aDescription anElement |
	anObject := CFMagritteEditorExample exampleDefault.
	aMemento := GtMagritteMemento model: anObject.
	aDescription := aMemento magritteDescription
		detect: [ :each | each handlesSelector: #label ].
	anElement := CFCompactObjectStencil new
		memento: aMemento;
		create.

	aMemento write: 'Draft title' using: aDescription.
	anElement refresh.

	self assert: anObject label equals: 'Editor example'.
	self assert: anElement titleText equals: 'Draft title'.

	aMemento reset.
	anElement refresh.
	self assert: anElement titleText equals: 'Editor example'.
	^ anElement
]

{ #category : 'examples' }
CFCompactObjectElementExamples >> compactObjectUsesDisplayFallback [
	<gtExample>
	| anObject anElement |
	anObject := CFMagritteEditorExample exampleDefault
		label: '';
		yourself.
	anElement := CFCompactObjectStencil new
		object: anObject;
		create.

	self assert: anElement titleText isNotEmpty.
	^ anElement
]

{ #category : 'examples' }
CFCompactObjectElementExamples >> compactPresentationSupportsObjectsWithoutIcons [
	<gtExample>
	| anElement |
	anElement := CFCompactObjectStencil new
		object: #aSymbol;
		create.

	self assert: anElement titleText equals: 'aSymbol'.
	self assert: anElement iconContainer visibility equals: BlVisibility gone.
	^ anElement
]

{ #category : 'examples' }
CFCompactObjectElementExamples >> toManyDefaultItemUsesCompactPresentation [
	<gtExample>
	| anObject aViewModel aDescription anElement |
	anObject := CFMagritteEditorExample exampleDefault.
	aViewModel := anObject asGtMagritteViewModel.
	aDescription := CFToManyRelationDescription new.
	anElement := aDescription blocItemStencil
		listElement: BrFrame new;
		rowValue: aViewModel;
		rowIndex: 1;
		build.

	self assert: anElement class equals: CFCompactObjectElement.
	self assert: anElement displayedObject == anObject.
	^ anElement
]

{ #category : 'examples' }
CFCompactObjectElementExamples >> toOneDefaultItemUsesCompactPresentation [
	<gtExample>
	| anObject aViewModel aDescription anElement |
	anObject := CFMagritteEditorExample exampleDefault.
	aViewModel := anObject asGtMagritteViewModel.
	aDescription := CFToOneRelationDescription new.
	anElement := aDescription blocItemStencil
		listElement: BrFrame new;
		rowValue: aViewModel;
		rowIndex: 1;
		build.

	self assert: anElement class equals: CFCompactObjectElement.
	self assert: anElement displayedObject == anObject.
	^ anElement
]

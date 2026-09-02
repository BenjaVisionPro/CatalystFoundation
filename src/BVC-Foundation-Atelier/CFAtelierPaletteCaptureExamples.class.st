"I prove that a configured Atelier palette can be a composition destination without imposing a storage or cloning policy on Atelier."
Class {
	#name : 'CFAtelierPaletteCaptureExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - capture' }
CFAtelierPaletteCaptureExamples >> paletteCaptureIsExplicitlyConfigured [
	<gtExample>
	| palette object item |
	palette := CFAtelierPalette new.
	object := Object new.

	self assert: palette canCapture not.
	self assert: (palette capture: object) isNil.
	self assert: palette items isEmpty.

	palette captureUsing: [ :captured |
		CFAtelierPaletteItem
			label: 'Captured'
			provider: (CFAtelierExistingObjectProvider object: captured) ].
	item := palette capture: object.

	self assert: palette canCapture.
	self assert: palette items size equals: 1.
	self assert: palette items first == item.
	self assert: item materialize == object.
	^ palette
]

{ #category : 'examples - capture UI' }
CFAtelierPaletteCaptureExamples >> relationDragCapturesExactExistingIdentity [
	<gtExample>
	| model memento object description sourceElement dragItem palette paletteElement item |
	model := CFAtelierMoveExampleModel new.
	object := Object new.
	model leftItems: (OrderedCollection with: object).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	sourceElement := BlElement new.
	sourceElement userData
		at: #atelierRelationDragContext
		put: (CFAtelierRelationDragContext memento: memento description: description).
	dragItem := BlDragItem new
		sourceElement: sourceElement;
		domainObject: object;
		yourself.
	palette := CFAtelierPalette new.
	palette captureUsing: [ :captured |
		CFAtelierPaletteItem
			label: 'Existing'
			provider: (CFAtelierExistingObjectProvider object: captured) ].
	paletteElement := CFAtelierPaletteElement new
		palette: palette;
		yourself.

	item := paletteElement captureDragItem: dragItem.

	self assert: item notNil.
	self assert: item materialize == object.
	self assert: (memento readUsing: description) first == object.
	self assert: model leftItems first == object.
	^ paletteElement
]

{ #category : 'examples - capture UI' }
CFAtelierPaletteCaptureExamples >> staleRelationDragIsNotCaptured [
	<gtExample>
	| model memento object description sourceElement dragItem palette paletteElement |
	model := CFAtelierMoveExampleModel new.
	object := Object new.
	model leftItems: (OrderedCollection with: object).
	memento := CFMaMemento model: model.
	description := self descriptionFor: #leftItems in: memento.
	sourceElement := BlElement new.
	sourceElement userData
		at: #atelierRelationDragContext
		put: (CFAtelierRelationDragContext memento: memento description: description).
	dragItem := BlDragItem new
		sourceElement: sourceElement;
		domainObject: object;
		yourself.
	palette := CFAtelierPalette new.
	palette captureUsing: [ :captured |
		CFAtelierPaletteItem
			label: 'Existing'
			provider: (CFAtelierExistingObjectProvider object: captured) ].
	paletteElement := CFAtelierPaletteElement new
		palette: palette;
		yourself.
	memento write: OrderedCollection new using: description.

	self assert: (paletteElement captureDragItem: dragItem) isNil.
	self assert: palette items isEmpty.
	^ paletteElement
]

{ #category : 'private' }
CFAtelierPaletteCaptureExamples >> descriptionFor: aSelector in: aMemento [
	^ aMemento magritteDescription detect: [ :each | each handlesSelector: aSelector ]
]

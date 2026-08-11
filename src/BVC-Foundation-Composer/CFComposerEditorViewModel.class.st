Class {
	#name : 'CFComposerEditorViewModel',
	#superclass : 'CFMaViewModel',
	#instVars : [
		'formController'
	],
	#category : 'BVC-Foundation-Composer',
	#package : 'BVC-Foundation-Composer'
}

{ #category : 'instance creation' }
CFComposerEditorViewModel class >> forMemento: aMemento formController: aFormController [
	^ self new
		mementoBlock: [ aMemento ] object: aMemento model;
		formController: aFormController;
		yourself
]

{ #category : 'accessing' }
CFComposerEditorViewModel >> formController [
	^ formController
]

{ #category : 'accessing' }
CFComposerEditorViewModel >> formController: aComposerFormController [
	formController := aComposerFormController
]

{ #category : 'initialization' }
CFComposerEditorViewModel >> initialize [
	super initialize.
	self ignoreImplicitActions
]

{ #category : 'initialization' }
CFComposerEditorViewModel >> initializeForm: theFrame forMemento: aMemento [
	| aContainer aStencil |
	formController ifNil: [
		formController := CFComposerFormController withRootMemento: aMemento ].
	theFrame userData at: self class gtMementoSymbol put: aMemento.
	theFrame removeChildren.

	aStencil := self formContainerStencilForMemento: aMemento.
	aContainer := aStencil
		memento: aMemento;
		asElement.
	theFrame addChild: aContainer.
	aContainer requestStyle.

	CFComposerElementBuilder new
		includeImplicitActions: false;
		form: theFrame;
		memento: aMemento;
		formController: formController;
		addButtons: (aMemento == formController rootMemento
			ifTrue: [ self actions ]
			ifFalse: [ #() ]);
		build.
	^ self onElementCreated cull: theFrame
]

Class {
	#name : 'CFComposerRelationElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'memento',
		'description',
		'formController'
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
	self relationItems do: [ :each |
		| aChildMemento aChildViewModel |
		aChildMemento := formController
			registerMemento: (GtMagritteMemento model: each)
			below: memento.
		aChildViewModel := CFComposerEditorViewModel
			forMemento: aChildMemento
			formController: formController.
		self addChild: (aChildViewModel asEmbeddedElement
			hMatchParent;
			vFitContent;
			yourself) ]
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

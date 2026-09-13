"I am a Phlow tool for one Foundation Magritte editing context.

Unlike the default inspector tool, I preserve the caller-supplied CFMaMemento so Tree Pager navigation remains inside the same editing transaction. The object is navigation identity; the memento is editing identity.

I can prepare my next element before a Tree Pager branch is changed. The pager therefore receives a complete Foundation form instead of exposing Magritte's asynchronous construction as temporary UI."
Class {
	#name : 'CFMaMementoTool',
	#superclass : 'GtPhlowTool',
	#instVars : [
		'object',
		'memento',
		'presentationBlock',
		'preparedElement'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'instance creation' }
CFMaMementoTool class >> object: anObject memento: aMemento [
	^ self new
		object: anObject;
		memento: aMemento;
		yourself
]

{ #category : 'api - converting' }
CFMaMementoTool >> asElementDo: aOneArgBlock [
	| element |
	preparedElement ifNotNil: [
		element := preparedElement.
		preparedElement := nil.
		^ aOneArgBlock cull: element cull: self ].
	element := self newElementReadyDo: [ :aReadyElement | ].
	^ aOneArgBlock cull: element cull: self
]

{ #category : 'accessing' }
CFMaMementoTool >> memento [
	^ memento
]

{ #category : 'accessing' }
CFMaMementoTool >> memento: aMemento [
	memento := aMemento
]

{ #category : 'private - building' }
CFMaMementoTool >> newElementReadyDo: aBlock [
	| viewModel |
	viewModel := CFMaViewModel forObject: object memento: memento.
	viewModel
		ignoreImplicitActions;
		elementBuilderDo: [ CFMaDetailPresentation new beOverlay ];
		onElementCreated: [ :aFormElement | aBlock value: aFormElement ].
	presentationBlock ifNotNil: [ :aPresentationBlock |
		viewModel presentationDo: aPresentationBlock ].
	^ viewModel asElement
]

{ #category : 'accessing' }
CFMaMementoTool >> object [
	^ object
]

{ #category : 'accessing' }
CFMaMementoTool >> object: anObject [
	object := anObject
]

{ #category : 'preparing' }
CFMaMementoTool >> prepareElementDo: aBlock [
	preparedElement ifNotNil: [
		^ aBlock value: self ].
	self newElementReadyDo: [ :aReadyElement |
		preparedElement := aReadyElement.
		aBlock value: self ]
]

{ #category : 'configuration' }
CFMaMementoTool >> presentationDo: aBlock [
	presentationBlock := aBlock
]

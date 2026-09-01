Class {
	#name : 'CFCompactObjectStencil',
	#superclass : 'BrStencil',
	#instVars : [
		'object',
		'memento',
		'reference'
	],
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFCompactObjectStencil >> create [
	| anElement |
	anElement := CFCompactObjectElement new.
	memento
		ifNil: [ anElement object: object ]
		ifNotNil: [ anElement memento: memento ].
	anElement reference: reference.
	^ anElement
]

{ #category : 'accessing' }
CFCompactObjectStencil >> memento [
	^ memento
]

{ #category : 'accessing' }
CFCompactObjectStencil >> memento: aMemento [
	memento := aMemento.
	object := aMemento ifNil: [ nil ] ifNotNil: #model
]

{ #category : 'accessing' }
CFCompactObjectStencil >> object [
	^ object
]

{ #category : 'accessing' }
CFCompactObjectStencil >> object: anObject [
	object := anObject.
	memento := nil
]

{ #category : 'accessing' }
CFCompactObjectStencil >> reference [
	^ reference
]

{ #category : 'accessing' }
CFCompactObjectStencil >> reference: aReferenceDescription [
	reference := aReferenceDescription
]

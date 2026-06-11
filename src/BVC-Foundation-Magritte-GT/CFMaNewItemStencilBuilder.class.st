Class {
	#name : 'CFMaNewItemStencilBuilder',
	#superclass : 'BrStencilBuilder',
	#instVars : [
		'itemClass',
		'memento',
		'description'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'accessing' }
CFMaNewItemStencilBuilder >> description [
	^ description
]

{ #category : 'accessing' }
CFMaNewItemStencilBuilder >> description: anObject [
	description := anObject
]

{ #category : 'accessing' }
CFMaNewItemStencilBuilder >> itemClass [
	^ itemClass
]

{ #category : 'accessing' }
CFMaNewItemStencilBuilder >> itemClass: anObject [
	itemClass := anObject
]

{ #category : 'accessing' }
CFMaNewItemStencilBuilder >> memento [
	^ memento
]

{ #category : 'accessing' }
CFMaNewItemStencilBuilder >> memento: anObject [
	memento := anObject
]

{ #category : 'api - instantiation' }
CFMaNewItemStencilBuilder >> buildDefault [
	self itemClass ifNil: [ ^ nil ].
	^ self itemClass new
]

{ #category : 'api - instantiation' }
CFMaNewItemStencilBuilder >> paramsOn: aStencilExecutor [
	super paramsOn: aStencilExecutor.
	aStencilExecutor
		push: self itemClass;
		push: self memento;
		push: self description
]

{ #category : 'initialization' }
CFMaNewItemStencilBuilder >> reset [
	itemClass := nil.
	memento := nil.
	description := nil
]

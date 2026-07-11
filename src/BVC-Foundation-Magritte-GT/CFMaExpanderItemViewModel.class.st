Class {
	#name : 'CFMaExpanderItemViewModel',
	#superclass : 'CFMaViewModel',
	#instVars : [
		'itemMemento',
		'expanded'
	],
	#category : 'BVC-Foundation-Magritte-GT-View Models',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'View Models'
}

{ #category : 'api - instance creation' }
CFMaExpanderItemViewModel class >> forObject: anObject [
	| aMemento |
	aMemento := GtMagritteMemento model: anObject.
	^ self new
		itemMemento: aMemento;
		mementoBlock: [ aMemento ] object: anObject;
		yourself
]

{ #category : 'accessing' }
CFMaExpanderItemViewModel >> elementClass [
	^ CFMaExpanderItemElement
]

{ #category : 'accessing' }
CFMaExpanderItemViewModel >> expanded [
	^ expanded
]

{ #category : 'accessing' }
CFMaExpanderItemViewModel >> expanded: aBoolean [
	expanded := aBoolean
]

{ #category : 'initialization' }
CFMaExpanderItemViewModel >> initialize [
	super initialize.
	expanded := false
]

{ #category : 'accessing' }
CFMaExpanderItemViewModel >> itemMemento [
	^ itemMemento
]

{ #category : 'private - accessing' }
CFMaExpanderItemViewModel >> itemMemento: aMemento [
	itemMemento := aMemento
]

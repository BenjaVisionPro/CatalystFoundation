Class {
	#name : 'CFMaAccordionItemViewModel',
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
CFMaAccordionItemViewModel class >> forObject: anObject [
	| aMemento |
	aMemento := GtMagritteMemento model: anObject.
	^ self new
		itemMemento: aMemento;
		mementoBlock: [ aMemento ] object: anObject;
		yourself
]

{ #category : 'accessing' }
CFMaAccordionItemViewModel >> expanded [
	^ expanded
]

{ #category : 'accessing' }
CFMaAccordionItemViewModel >> expanded: aBoolean [
	expanded := aBoolean
]

{ #category : 'initialization' }
CFMaAccordionItemViewModel >> initialize [
	super initialize.
	expanded := false
]

{ #category : 'accessing' }
CFMaAccordionItemViewModel >> itemMemento [
	^ itemMemento
]

{ #category : 'private - accessing' }
CFMaAccordionItemViewModel >> itemMemento: aMemento [
	itemMemento := aMemento
]

"I am the deliberately small Magritte model used to prove Atelier cross-relation move semantics."
Class {
	#name : 'CFAtelierMoveExampleModel',
	#superclass : 'Object',
	#instVars : [
		'leftItems',
		'rightItems',
		'rightItemLimit'
	],
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'initialization' }
CFAtelierMoveExampleModel >> initialize [
	super initialize.
	leftItems := OrderedCollection new.
	rightItems := OrderedCollection new.
	rightItemLimit := 1000
]

{ #category : 'accessing' }
CFAtelierMoveExampleModel >> leftItems [
	^ leftItems
]

{ #category : 'accessing' }
CFAtelierMoveExampleModel >> leftItems: aCollection [
	leftItems := aCollection
]

{ #category : 'descriptions' }
CFAtelierMoveExampleModel >> leftItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #leftItems;
		label: 'Left';
		classes: { Object };
		beModifiable;
		beOrdered;
		yourself
]

{ #category : 'accessing' }
CFAtelierMoveExampleModel >> rightItemLimit [
	^ rightItemLimit
]

{ #category : 'accessing' }
CFAtelierMoveExampleModel >> rightItemLimit: anInteger [
	rightItemLimit := anInteger
]

{ #category : 'accessing' }
CFAtelierMoveExampleModel >> rightItems [
	^ rightItems
]

{ #category : 'accessing' }
CFAtelierMoveExampleModel >> rightItems: aCollection [
	rightItems := aCollection
]

{ #category : 'descriptions' }
CFAtelierMoveExampleModel >> rightItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #rightItems;
		label: 'Right';
		classes: { Object };
		beModifiable;
		beOrdered;
		addCondition: [ :aCollection | aCollection size <= rightItemLimit ]
			labelled: 'The right relation has reached its configured limit.';
		yourself
]

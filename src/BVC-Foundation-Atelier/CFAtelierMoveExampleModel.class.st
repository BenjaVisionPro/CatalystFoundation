"I am the deliberately small Magritte model used to prove Atelier cross-relation move semantics."
Class {
	#name : 'CFAtelierMoveExampleModel',
	#superclass : 'Object',
	#instVars : [
		'leftItems',
		'rightItems',
		'looseItems',
		'leftItem',
		'rightItem',
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
	looseItems := OrderedCollection new.
	leftItem := nil.
	rightItem := nil.
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

{ #category : 'accessing' }
CFAtelierMoveExampleModel >> looseItems [
	^ looseItems
]

{ #category : 'accessing' }
CFAtelierMoveExampleModel >> looseItems: aCollection [
	looseItems := aCollection
]

{ #category : 'descriptions' }
CFAtelierMoveExampleModel >> looseItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #looseItems;
		label: 'Loose';
		classes: { Object };
		beModifiable;
		yourself
]


{ #category : 'accessing' }
CFAtelierMoveExampleModel >> leftItem [ ^ leftItem ]

{ #category : 'accessing' }
CFAtelierMoveExampleModel >> leftItem: anObject [ leftItem := anObject ]

{ #category : 'descriptions' }
CFAtelierMoveExampleModel >> leftItemDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #leftItem;
		label: 'Left item';
		classes: { Object };
		yourself
]

{ #category : 'accessing' }
CFAtelierMoveExampleModel >> rightItem [ ^ rightItem ]

{ #category : 'accessing' }
CFAtelierMoveExampleModel >> rightItem: anObject [ rightItem := anObject ]

{ #category : 'descriptions' }
CFAtelierMoveExampleModel >> rightItemDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #rightItem;
		label: 'Right item';
		classes: { Object };
		yourself
]

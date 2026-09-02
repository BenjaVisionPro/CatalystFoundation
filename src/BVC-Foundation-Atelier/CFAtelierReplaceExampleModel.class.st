"I am the small Magritte model used to prove Atelier replacement across both to-one and to-many relation cardinalities."
Class {
	#name : 'CFAtelierReplaceExampleModel',
	#superclass : 'Object',
	#instVars : [
		'primaryItem',
		'items'
	],
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'initialization' }
CFAtelierReplaceExampleModel >> initialize [
	super initialize.
	items := OrderedCollection new
]

{ #category : 'accessing' }
CFAtelierReplaceExampleModel >> items [ ^ items ]
{ #category : 'accessing' }
CFAtelierReplaceExampleModel >> items: aCollection [ items := aCollection ]

{ #category : 'descriptions' }
CFAtelierReplaceExampleModel >> itemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #items;
		label: 'Items';
		classes: { Object };
		beModifiable;
		beOrdered;
		yourself
]

{ #category : 'accessing' }
CFAtelierReplaceExampleModel >> primaryItem [ ^ primaryItem ]
{ #category : 'accessing' }
CFAtelierReplaceExampleModel >> primaryItem: anObject [ primaryItem := anObject ]

{ #category : 'descriptions' }
CFAtelierReplaceExampleModel >> primaryItemDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #primaryItem;
		label: 'Primary item';
		classes: { Object };
		beModifiable;
		yourself
]

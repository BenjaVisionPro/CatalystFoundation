Class {
	#name : 'CFComposerExampleGroup',
	#superclass : 'Object',
	#instVars : [
		'name',
		'children'
	],
	#category : 'BVC-Foundation-Composer-Examples',
	#package : 'BVC-Foundation-Composer',
	#tag : 'Examples'
}

{ #category : 'accessing' }
CFComposerExampleGroup >> children [
	^ children
]

{ #category : 'accessing' }
CFComposerExampleGroup >> children: aCollection [
	children := aCollection
]

{ #category : 'magritte' }
CFComposerExampleGroup >> childrenDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #children;
		label: 'Children';
		classes: { CFComposerExampleModel };
		priority: 20;
		yourself
]

{ #category : 'initialization' }
CFComposerExampleGroup >> initialize [
	super initialize.
	name := 'Composer group'.
	children := OrderedCollection withAll: {
		CFComposerExampleModel new name: 'First child'; yourself.
		CFComposerExampleModel new name: 'Second child'; yourself }
]

{ #category : 'accessing' }
CFComposerExampleGroup >> name [
	^ name
]

{ #category : 'accessing' }
CFComposerExampleGroup >> name: aString [
	name := aString
]

{ #category : 'magritte' }
CFComposerExampleGroup >> nameDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #name;
		label: 'Name';
		priority: 10;
		beRequired;
		yourself
]

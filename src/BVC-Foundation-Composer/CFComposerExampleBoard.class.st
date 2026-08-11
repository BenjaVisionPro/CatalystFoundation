Class {
	#name : 'CFComposerExampleBoard',
	#superclass : 'Object',
	#instVars : [
		'name',
		'palette',
		'composition'
	],
	#category : 'BVC-Foundation-Composer-Examples',
	#package : 'BVC-Foundation-Composer',
	#tag : 'Examples'
}

{ #category : 'accessing' }
CFComposerExampleBoard >> composition [
	^ composition
]

{ #category : 'accessing' }
CFComposerExampleBoard >> composition: aCollection [
	composition := aCollection
]

{ #category : 'magritte' }
CFComposerExampleBoard >> compositionDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #composition;
		label: 'Composition';
		classes: { CFComposerExampleModel };
		priority: 30;
		yourself
]

{ #category : 'initialization' }
CFComposerExampleBoard >> initialize [
	super initialize.
	name := 'Composer board'.
	palette := OrderedCollection withAll: {
		CFComposerExampleModel new name: 'Available first'; yourself.
		CFComposerExampleModel new name: 'Available second'; yourself }.
	composition := OrderedCollection new
]

{ #category : 'accessing' }
CFComposerExampleBoard >> name [
	^ name
]

{ #category : 'accessing' }
CFComposerExampleBoard >> name: aString [
	name := aString
]

{ #category : 'magritte' }
CFComposerExampleBoard >> nameDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #name;
		label: 'Name';
		priority: 10;
		beRequired;
		yourself
]

{ #category : 'accessing' }
CFComposerExampleBoard >> palette [
	^ palette
]

{ #category : 'accessing' }
CFComposerExampleBoard >> palette: aCollection [
	palette := aCollection
]

{ #category : 'magritte' }
CFComposerExampleBoard >> paletteDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #palette;
		label: 'Palette';
		classes: { CFComposerExampleModel };
		priority: 20;
		yourself
]

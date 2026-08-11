Class {
	#name : 'CFComposerExampleModel',
	#superclass : 'Object',
	#instVars : [
		'name'
	],
	#category : 'BVC-Foundation-Composer-Examples',
	#package : 'BVC-Foundation-Composer',
	#tag : 'Examples'
}

{ #category : 'accessing' }
CFComposerExampleModel >> name [
	^ name
]

{ #category : 'accessing' }
CFComposerExampleModel >> name: aString [
	name := aString
]

{ #category : 'initialization' }
CFComposerExampleModel >> initialize [
	super initialize.
	name := 'Composer example'
]

{ #category : 'magritte' }
CFComposerExampleModel >> nameDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #name;
		label: 'Name';
		beRequired;
		yourself
]

"I am an ordinary Magritte-described object used to prove Atelier's public entry path."
Class {
	#name : 'CFAtelierEntryExampleModel',
	#superclass : 'Object',
	#instVars : [
		'name'
	],
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'initialization' }
CFAtelierEntryExampleModel >> initialize [
	super initialize.
	name := 'Atelier example'
]

{ #category : 'accessing' }
CFAtelierEntryExampleModel >> name [
	^ name
]

{ #category : 'accessing' }
CFAtelierEntryExampleModel >> name: aString [
	name := aString
]

{ #category : 'magritte descriptions' }
CFAtelierEntryExampleModel >> nameDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #name;
		label: 'Name';
		yourself
]

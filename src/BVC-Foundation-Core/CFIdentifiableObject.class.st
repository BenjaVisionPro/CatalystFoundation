Class {
	#name : 'CFIdentifiableObject',
	#superclass : 'CFObject',
	#instVars : [
		'identifier'
	],
	#category : 'BVC-Foundation-Core-Extensions',
	#package : 'BVC-Foundation-Core',
	#tag : 'Extensions'
}

{ #category : 'instance creation' }
CFIdentifiableObject class >> identifier: anIdentifier [
	^ self basicNew
		identifier: anIdentifier;
		initialize
]

{ #category : 'accessing' }
CFIdentifiableObject >> identifier [
	^ identifier
]

{ #category : 'private - accessing' }
CFIdentifiableObject >> identifier: anObject [
	identifier := anObject
]

{ #category : 'descriptions' }
CFIdentifiableObject >> identifierDescription [
	<magritteDescription>
	^ MASymbolDescription new
		accessor: #identifier;
		label: 'Identifier';
		priority: 10;
		beRequired;
		yourself
]

{ #category : 'as yet unclassified' }
CFIdentifiableObject >> initialize [
	super initialize.
	identifier ifNil: [ identifier := UUID new ]
]

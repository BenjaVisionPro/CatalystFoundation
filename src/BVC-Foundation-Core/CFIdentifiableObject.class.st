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
		cfCategory: #identity;
		cfSerializable: true;
		yourself
]

{ #category : 'as yet unclassified' }
CFIdentifiableObject >> initialize [
	super initialize.
	self initializeIdentifier
]

{ #category : 'as yet unclassified' }
CFIdentifiableObject >> initializeIdentifier [
	identifier := (String
			streamContents: [ :idString | 
				idString
					nextPutAll: 'cf_';
					nextPutAll: UUID new asString36 ]) asSymbol
]

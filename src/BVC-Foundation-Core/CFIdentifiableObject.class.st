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

{ #category : 'as yet unclassified' }
CFIdentifiableObject >> initialize [
	super initialize.
	self initializeIdentifier
]

{ #category : 'as yet unclassified' }
CFIdentifiableObject >> initializeIdentifier [
	identifier ifNotNil: [ ^ self ].
	identifier := UUID new asString36 asSymbol
]

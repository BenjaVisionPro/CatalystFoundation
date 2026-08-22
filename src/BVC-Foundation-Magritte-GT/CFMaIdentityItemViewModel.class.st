"
I am responsible for carrying one relation object and its Foundation child memento into an editable identity affordance.
"
Class {
	#name : 'CFMaIdentityItemViewModel',
	#superclass : 'Object',
	#instVars : [
		'object',
		'memento'
	],
	#category : 'BVC-Foundation-Magritte-GT-View Models',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'View Models'
}

{ #category : 'instance creation' }
CFMaIdentityItemViewModel class >> object: anObject memento: aMemento [
	^ self new
		object: anObject;
		memento: aMemento;
		yourself
]

{ #category : 'testing' }
CFMaIdentityItemViewModel >> isForObject: anObject [
	^ object == anObject
]

{ #category : 'accessing' }
CFMaIdentityItemViewModel >> memento [
	^ memento
]

{ #category : 'accessing' }
CFMaIdentityItemViewModel >> memento: aMemento [
	memento := aMemento
]

{ #category : 'accessing' }
CFMaIdentityItemViewModel >> object [
	^ object
]

{ #category : 'accessing' }
CFMaIdentityItemViewModel >> object: anObject [
	object := anObject
]

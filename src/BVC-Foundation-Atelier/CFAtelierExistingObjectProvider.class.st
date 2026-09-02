"I explicitly supply an already-existing object identity.

Each materialize answers the same object. Operations such as reference/reuse may use that identity without implying copy or ownership transfer."
Class {
	#name : 'CFAtelierExistingObjectProvider',
	#superclass : 'CFAtelierObjectProvider',
	#instVars : [
		'object'
	],
	#category : 'BVC-Foundation-Atelier-Supply',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Supply'
}

{ #category : 'instance creation' }
CFAtelierExistingObjectProvider class >> object: anObject [
	^ self new
		object: anObject;
		yourself
]

{ #category : 'materializing' }
CFAtelierExistingObjectProvider >> materialize [
	^ object
]

{ #category : 'accessing' }
CFAtelierExistingObjectProvider >> object [
	^ object
]

{ #category : 'accessing' }
CFAtelierExistingObjectProvider >> object: anObject [
	object := anObject
]

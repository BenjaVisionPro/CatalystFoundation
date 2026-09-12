Class {
	#name : 'CFMaFieldContext',
	#superclass : 'Object',
	#instVars : [
		'description',
		'memento'
	],
	#category : 'BVC-Foundation-Magritte-GT-Models',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Models'
}

{ #category : 'instance creation' }
CFMaFieldContext class >> description: aDescription memento: aMemento [
	^ self new
		description: aDescription;
		memento: aMemento;
		yourself
]

{ #category : 'accessing' }
CFMaFieldContext >> description [
	^ description
]

{ #category : 'private - initialization' }
CFMaFieldContext >> description: aDescription [
	description := aDescription
]

{ #category : 'accessing' }
CFMaFieldContext >> memento [
	^ memento
]

{ #category : 'private - initialization' }
CFMaFieldContext >> memento: aMemento [
	memento := aMemento
]

{ #category : 'accessing' }
CFMaFieldContext >> model [
	^ memento model
]

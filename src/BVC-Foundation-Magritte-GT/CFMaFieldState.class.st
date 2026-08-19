"I expose the native Magritte value and validation observables for one description without imposing any presentation geometry."

Class {
	#name : 'CFMaFieldState',
	#superclass : 'Object',
	#instVars : [
		'memento',
		'description'
	],
	#category : 'BVC-Foundation-Magritte-GT-Model',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Model'
}

{ #category : 'instance creation' }
CFMaFieldState class >> memento: aMemento description: aDescription [
	^ self new
		memento: aMemento;
		description: aDescription;
		yourself
]

{ #category : 'accessing' }
CFMaFieldState >> description [
	^ description
]

{ #category : 'accessing' }
CFMaFieldState >> description: aDescription [
	description := aDescription
]

{ #category : 'accessing' }
CFMaFieldState >> memento [
	^ memento
]

{ #category : 'accessing' }
CFMaFieldState >> memento: aMemento [
	memento := aMemento
]

{ #category : 'observing' }
CFMaFieldState >> observableValue [
	^ memento readObservableValueUsing: description
]

{ #category : 'observing' }
CFMaFieldState >> observableValidation [
	^ memento validatorUsing: description
]

{ #category : 'accessing' }
CFMaFieldState >> isChangeIndicatorEnabled [
	^ description isWithChangeIndicator
]

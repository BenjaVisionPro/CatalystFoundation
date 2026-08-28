Class {
	#name : 'CFMaEnablementCondition',
	#superclass : 'Object',
	#instVars : [
		'description',
		'expectedValue'
	],
	#category : 'BVC-Foundation-Magritte-Core-Field',
	#package : 'BVC-Foundation-Magritte-Core',
	#tag : 'Field'
}

{ #category : 'instance creation' }
CFMaEnablementCondition class >> description: aDescription equals: anObject [
	^ self new
		description: aDescription;
		expectedValue: anObject;
		yourself
]

{ #category : 'accessing' }
CFMaEnablementCondition >> description [
	^ description
]

{ #category : 'accessing' }
CFMaEnablementCondition >> description: aDescription [
	description := aDescription
]

{ #category : 'accessing' }
CFMaEnablementCondition >> expectedValue [
	^ expectedValue
]

{ #category : 'accessing' }
CFMaEnablementCondition >> expectedValue: anObject [
	expectedValue := anObject
]

{ #category : 'testing' }
CFMaEnablementCondition >> matches: anObject [
	^ anObject = expectedValue
]

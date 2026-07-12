Class {
	#name : 'CFConfigurationValidationIssue',
	#superclass : 'Object',
	#instVars : [
		'code',
		'message',
		'path',
		'severity',
		'subject'
	],
	#category : 'BVC-Foundation-Config-Validation',
	#package : 'BVC-Foundation-Config-Validation'
}

{ #category : 'instance creation' }
CFConfigurationValidationIssue class >> code: aSymbol message: aString severity: aSeverity subject: anObject path: aCollection [
	^ self new
		code: aSymbol;
		message: aString;
		severity: aSeverity;
		subject: anObject;
		path: aCollection;
		yourself
]

{ #category : 'accessing' }
CFConfigurationValidationIssue >> code [
	^ code
]

{ #category : 'accessing' }
CFConfigurationValidationIssue >> code: aSymbol [
	code := aSymbol
]

{ #category : 'testing' }
CFConfigurationValidationIssue >> isError [
	^ severity = #error
]

{ #category : 'accessing' }
CFConfigurationValidationIssue >> message [
	^ message
]

{ #category : 'accessing' }
CFConfigurationValidationIssue >> message: aString [
	message := aString
]

{ #category : 'accessing' }
CFConfigurationValidationIssue >> path [
	^ path
]

{ #category : 'accessing' }
CFConfigurationValidationIssue >> path: aCollection [
	path := aCollection ifNil: [ #() ]
]

{ #category : 'accessing' }
CFConfigurationValidationIssue >> severity [
	^ severity
]

{ #category : 'accessing' }
CFConfigurationValidationIssue >> severity: aSymbol [
	severity := aSymbol
]

{ #category : 'accessing' }
CFConfigurationValidationIssue >> subject [
	^ subject
]

{ #category : 'accessing' }
CFConfigurationValidationIssue >> subject: anObject [
	subject := anObject
]

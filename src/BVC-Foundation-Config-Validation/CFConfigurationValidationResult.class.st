Class {
	#name : 'CFConfigurationValidationResult',
	#superclass : 'Object',
	#instVars : [
		'issues'
	],
	#category : 'BVC-Foundation-Config-Validation',
	#package : 'BVC-Foundation-Config-Validation'
}

{ #category : 'adding' }
CFConfigurationValidationResult >> addErrorCode: aSymbol message: aString subject: anObject path: aCollection [
	issues add: (CFConfigurationValidationIssue
		code: aSymbol
		message: aString
		severity: #error
		subject: anObject
		path: aCollection)
]

{ #category : 'adding' }
CFConfigurationValidationResult >> addWarningCode: aSymbol message: aString subject: anObject path: aCollection [
	issues add: (CFConfigurationValidationIssue
		code: aSymbol
		message: aString
		severity: #warning
		subject: anObject
		path: aCollection)
]

{ #category : 'accessing' }
CFConfigurationValidationResult >> errors [
	^ issues select: #isError
]

{ #category : 'initialization' }
CFConfigurationValidationResult >> initialize [
	super initialize.
	issues := OrderedCollection new
]

{ #category : 'testing' }
CFConfigurationValidationResult >> isValid [
	^ self errors isEmpty
]

{ #category : 'accessing' }
CFConfigurationValidationResult >> issues [
	^ issues
]

{ #category : 'accessing' }
CFConfigurationValidationResult >> warnings [
	^ issues select: [ :each | each severity = #warning ]
]

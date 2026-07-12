Class {
	#name : 'CFConfigurationValidator',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Config-Validation',
	#package : 'BVC-Foundation-Config-Validation'
}

{ #category : 'private - validation' }
CFConfigurationValidator >> addMagritteError: anError subject: aConfiguration to: aValidationResult [
	(anError isKindOf: MAMultipleErrors)
		ifTrue: [
			anError collection do: [ :each |
				self addMagritteError: each subject: aConfiguration to: aValidationResult ].
			^ aValidationResult ].
	aValidationResult
		addErrorCode: #magritteValidation
		message: anError messageText
		subject: aConfiguration
		path: (anError tag
			ifNil: [ #() ]
			ifNotNil: [ :aDescription | { aDescription accessor readSelector } ])
]

{ #category : 'validation' }
CFConfigurationValidator >> validate: aConfiguration [
	| result |
	result := CFConfigurationValidationResult new.
	aConfiguration ifNil: [
		result
			addErrorCode: #missingConfiguration
			message: 'A configuration is required.'
			subject: nil
			path: #().
		^ result ].
	self validateMagritteOf: aConfiguration on: result.
	aConfiguration validateConfigurationGraphOn: result.
	^ result
]

{ #category : 'private - validation' }
CFConfigurationValidator >> validateMagritteOf: aConfiguration on: aValidationResult [
	[ aConfiguration magritteDescription validate: aConfiguration ]
		on: MAValidationError
		do: [ :anError |
			self addMagritteError: anError subject: aConfiguration to: aValidationResult ]
]

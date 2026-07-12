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
	self validateMagritteConfigurationGraphRootedAt: aConfiguration on: result.
	aConfiguration validateConfigurationGraphOn: result.
	^ result
]

{ #category : 'private - validation' }
CFConfigurationValidator >> validateMagritteConfiguration: aConfiguration visited: visitedConfigurations on: aValidationResult [
	(visitedConfigurations includes: aConfiguration) ifTrue: [ ^ self ].
	visitedConfigurations add: aConfiguration.
	self validateMagritteOf: aConfiguration on: aValidationResult.
	(aConfiguration magritteDescription
		select: [ :each |
			(each isKindOf: MARelationDescription) and: [ each cfConfigurationEmbedded ] ])
		do: [ :each |
			self
				validateMagritteConfigurationsIn: (aConfiguration readUsing: each)
				visited: visitedConfigurations
				on: aValidationResult ]
]

{ #category : 'private - validation' }
CFConfigurationValidator >> validateMagritteConfigurationGraphRootedAt: aConfiguration on: aValidationResult [
	self
		validateMagritteConfiguration: aConfiguration
		visited: IdentitySet new
		on: aValidationResult
]

{ #category : 'private - validation' }
CFConfigurationValidator >> validateMagritteConfigurationsIn: aValue visited: visitedConfigurations on: aValidationResult [
	aValue ifNil: [ ^ self ].
	(aValue isCollection and: [ aValue isString not ])
		ifTrue: [
			aValue do: [ :each |
				self
					validateMagritteConfigurationsIn: each
					visited: visitedConfigurations
					on: aValidationResult ].
			^ self ].
	(aValue isKindOf: CFConfiguration) ifTrue: [
		self
			validateMagritteConfiguration: aValue
			visited: visitedConfigurations
			on: aValidationResult ]
]

{ #category : 'private - validation' }
CFConfigurationValidator >> validateMagritteOf: aConfiguration on: aValidationResult [
	[ aConfiguration magritteDescription validate: aConfiguration ]
		on: MAValidationError
		do: [ :anError |
			self addMagritteError: anError subject: aConfiguration to: aValidationResult ]
]
